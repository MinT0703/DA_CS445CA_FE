using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BestFoodRestaurant.Pages.Customer
{
    public partial class Booking : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Cài đặt ngày mặc định là hôm nay
                txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                txtTime.Text = DateTime.Now.AddHours(1).ToString("HH:mm");

                LoadTables();

                // Nếu đã đăng nhập, điền SĐT và load lịch sử
                if (Session["CustomerID"] != null)
                {
                    if (Session["CustomerPhone"] != null)
                        txtPhone.Text = Session["CustomerPhone"].ToString();

                    LoadHistory((int)Session["CustomerID"]);
                }
                else
                {
                    pnlLoginHint.Visible = true;
                    rptHistory.Visible = false;
                }
            }
        }

        private void LoadTables()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Chỉ lấy bàn đang 'AVAILABLE'
                string sql = "SELECT table_id, table_code, capacity FROM restaurant_tables WHERE status = 'AVAILABLE'";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            ListItem item = new ListItem();
                            item.Text = $"Bàn {r["table_code"]} ({r["capacity"]} chỗ)";
                            item.Value = r["table_id"].ToString();
                            ddlTable.Items.Add(item);
                        }
                    }
                }
            }
        }

        private void LoadHistory(int customerId)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT r.reservation_id, r.reservation_datetime, r.guest_count, r.note, r.status, t.table_code 
                    FROM reservations r
                    LEFT JOIN restaurant_tables t ON r.table_id = t.table_id
                    WHERE r.customer_id = @uid
                    ORDER BY r.reservation_datetime DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", customerId);
                    conn.Open();
                    rptHistory.DataSource = cmd.ExecuteReader();
                    rptHistory.DataBind();
                }
            }
            pnlLoginHint.Visible = false;
            rptHistory.Visible = true;
        }

        protected void btnBook_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;

            string phone = txtPhone.Text.Trim();
            string dateStr = txtDate.Text;
            string timeStr = txtTime.Text;
            string guestsStr = txtGuests.Text;
            string note = txtNote.Text.Trim();
            string tableVal = ddlTable.SelectedValue;

            // 1. Xác định Customer ID
            int customerId = 0;
            if (Session["CustomerID"] != null)
            {
                customerId = (int)Session["CustomerID"];
            }
            else
            {
                // Nếu chưa đăng nhập, thử tìm user qua số điện thoại
                customerId = GetUserIdByPhone(phone);
                if (customerId == 0)
                {
                    ShowMessage("Số điện thoại này chưa đăng ký thành viên. Vui lòng đăng ký trước khi đặt bàn.", false);
                    return;
                }
            }

            // 2. Validate Thời gian
            DateTime reserveTime;
            if (!DateTime.TryParse($"{dateStr} {timeStr}", out reserveTime))
            {
                ShowMessage("Ngày giờ không hợp lệ.", false);
                return;
            }
            if (reserveTime < DateTime.Now)
            {
                ShowMessage("Không thể đặt bàn trong quá khứ.", false);
                return;
            }

            // 3. Insert Database
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"INSERT INTO reservations (customer_id, table_id, reservation_datetime, guest_count, note, created_via, status, created_at) 
                               VALUES (@uid, @tid, @time, @guest, @note, 'WEB', 'PENDING', GETDATE())";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", customerId);

                    if (string.IsNullOrEmpty(tableVal)) cmd.Parameters.AddWithValue("@tid", DBNull.Value);
                    else cmd.Parameters.AddWithValue("@tid", int.Parse(tableVal));

                    cmd.Parameters.AddWithValue("@time", reserveTime);
                    cmd.Parameters.AddWithValue("@guest", int.Parse(guestsStr));
                    cmd.Parameters.AddWithValue("@note", note);

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();

                        ShowMessage("Đặt bàn thành công! Chúng tôi sẽ liên hệ sớm để xác nhận.", true);

                        // Reload history
                        LoadHistory(customerId);

                        // Clear form
                        txtNote.Text = "";
                        ddlTable.SelectedIndex = 0;
                    }
                    catch (Exception ex)
                    {
                        ShowMessage("Lỗi hệ thống: " + ex.Message, false);
                    }
                }
            }
        }

        private int GetUserIdByPhone(string phone)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT user_id FROM users WHERE phone = @p";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@p", phone);
                    conn.Open();
                    object res = cmd.ExecuteScalar();
                    if (res != null) return Convert.ToInt32(res);
                }
            }
            return 0;
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMsg.Text = msg;
            pnlMsg.CssClass = success ? "alert-box alert-success" : "alert-box alert-error";
            pnlMsg.Visible = true;
        }
    }
}