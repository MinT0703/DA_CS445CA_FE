using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.Script.Serialization; // Lưu ý: Cần Add Reference 'System.Web.Extensions' trong Project References

namespace BestFoodRestaurant.Pages.Customer
{
    public partial class Pay : System.Web.UI.Page
    {
        // Lấy chuỗi kết nối từ Web.config
        string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Kiểm tra nếu user đã đăng nhập server-side
                if (Session["CustomerID"] != null)
                {
                    // Có thể load thông tin user từ DB để điền sẵn vào form nếu muốn
                    // Ví dụ: txtFullName.Text = Session["CustomerName"].ToString();
                }
            }
        }

        protected void btnPlaceOrder_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;

            // 1. Lấy dữ liệu giỏ hàng từ HiddenField
            string jsonCart = hfCartJson.Value;
            if (string.IsNullOrEmpty(jsonCart) || jsonCart == "[]")
            {
                ShowAlert("Giỏ hàng trống!");
                return;
            }

            // 2. Deserialize JSON sang List object
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            List<CartItem> items = serializer.Deserialize<List<CartItem>>(jsonCart);

            if (items == null || items.Count == 0) return;

            // 3. Lấy thông tin từ Form nhập liệu
            string fullName = txtFullName.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();
            string note = txtNote.Text.Trim();
            string paymentMethod = hfPaymentMethod.Value;

            decimal totalAmount = 0;
            decimal.TryParse(hfTotalAmount.Value, out totalAmount);

            // Gộp thông tin giao hàng vào ghi chú (do bảng Orders trong DB mẫu không có cột Address)
            string fullOrderNote = $"[GIAO HÀNG] Tên: {fullName} - SĐT: {phone} - ĐC: {address}. Ghi chú: {note}";

            int? customerId = null;
            if (Session["CustomerID"] != null) customerId = (int)Session["CustomerID"];

            // --- BẮT ĐẦU TRANSACTION SQL ---
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlTransaction trans = conn.BeginTransaction();

                try
                {
                    // A. Insert vào bảng ORDERS
                    // Các cột: customer_id, order_time, status, total_amount, source, payment_status...
                    string sqlOrder = @"INSERT INTO orders (customer_id, order_time, status, total_amount, source, payment_status) 
                                        VALUES (@uid, GETDATE(), 'PENDING', @total, 'WEB', 'UNPAID'); 
                                        SELECT SCOPE_IDENTITY();";

                    SqlCommand cmdOrder = new SqlCommand(sqlOrder, conn, trans);
                    if (customerId.HasValue) cmdOrder.Parameters.AddWithValue("@uid", customerId.Value);
                    else cmdOrder.Parameters.AddWithValue("@uid", DBNull.Value);

                    cmdOrder.Parameters.AddWithValue("@total", totalAmount);

                    // Lấy OrderId vừa tạo
                    object orderIdObj = cmdOrder.ExecuteScalar();
                    long orderId = Convert.ToInt64(orderIdObj);

                    // B. Insert vào bảng ORDER_ITEMS (Chi tiết đơn hàng)
                    string sqlItem = @"INSERT INTO order_items (order_id, dish_id, quantity, unit_price, note, subtotal) 
                                       VALUES (@oid, @did, @qty, @price, @note, @sub)";

                    foreach (var item in items)
                    {
                        SqlCommand cmdItem = new SqlCommand(sqlItem, conn, trans);
                        cmdItem.Parameters.AddWithValue("@oid", orderId);
                        cmdItem.Parameters.AddWithValue("@did", item.id);
                        cmdItem.Parameters.AddWithValue("@qty", item.qty);
                        cmdItem.Parameters.AddWithValue("@price", item.price);
                        cmdItem.Parameters.AddWithValue("@note", fullOrderNote);
                        cmdItem.Parameters.AddWithValue("@sub", item.price * item.qty);
                        cmdItem.ExecuteNonQuery();
                    }

                    // C. Insert vào bảng PAYMENTS (Thông tin thanh toán)
                    string sqlPay = @"INSERT INTO payments (order_id, amount, method, status, created_at) 
                                      VALUES (@oid, @amt, @method, 'PENDING', GETDATE())";

                    SqlCommand cmdPay = new SqlCommand(sqlPay, conn, trans);
                    cmdPay.Parameters.AddWithValue("@oid", orderId);
                    cmdPay.Parameters.AddWithValue("@amt", totalAmount);
                    cmdPay.Parameters.AddWithValue("@method", paymentMethod);
                    cmdPay.ExecuteNonQuery();

                    // Hoàn tất Transaction
                    trans.Commit();

                    // Xóa giỏ hàng LocalStorage và chuyển hướng
                    string script = "localStorage.removeItem('bestfood_cart'); localStorage.removeItem('bestfood_coupon_discount'); alert('Đặt hàng thành công! Mã đơn: " + orderId + "'); window.location='Default.aspx';";
                    ScriptManager.RegisterStartupScript(this, GetType(), "OrderSuccess", script, true);
                }
                catch (Exception ex)
                {
                    // Gặp lỗi thì hoàn tác
                    trans.Rollback();
                    ShowAlert("Lỗi khi đặt hàng: " + ex.Message);
                }
            }
        }

        private void ShowAlert(string msg)
        {
            // Escape ký tự nháy đơn để tránh lỗi JS
            string cleanMsg = msg.Replace("'", "\\'");
            string script = $"alert('{cleanMsg}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "Alert", script, true);
        }

        // Class hỗ trợ nhận dữ liệu JSON
        public class CartItem
        {
            public int id { get; set; }
            public string name { get; set; }
            public decimal price { get; set; }
            public int qty { get; set; }
            public string image { get; set; }
        }
    }
}