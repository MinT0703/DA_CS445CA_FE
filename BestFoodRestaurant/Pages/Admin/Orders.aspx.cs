using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BestFoodRestaurant.Pages.Admin
{
    public partial class Orders : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;
        int pageSize = 10;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        // --- HELPER 1: Tạo Badge HTML cho trạng thái ---
        public string GetStatusBadge(object statusObj)
        {
            if (statusObj == null) return "";
            string status = statusObj.ToString();
            string cssClass = "st-pending";
            string text = status;

            switch (status)
            {
                case "PENDING": cssClass = "st-pending"; text = "Chờ xác nhận"; break;
                case "CONFIRMED": cssClass = "st-confirmed"; text = "Đã xác nhận"; break;
                case "PREPARING": cssClass = "st-preparing"; text = "Đang chuẩn bị"; break;
                case "DELIVERING": cssClass = "st-delivering"; text = "Đang giao"; break;
                case "COMPLETED": cssClass = "st-completed"; text = "Hoàn thành"; break;
                case "CANCELLED": cssClass = "st-cancelled"; text = "Đã hủy"; break;
            }
            return $"<span class='status-badge {cssClass}'>{text}</span>";
        }

        // --- HELPER 2: Hiển thị tên phương thức thanh toán ---
        public string GetPaymentMethodName(object methodObj)
        {
            if (methodObj == null || methodObj == DBNull.Value) return "<span style='color:#999'>Chưa TT</span>";
            string m = methodObj.ToString().ToUpper();

            if (m == "COD" || m == "CASH") return "Tiền mặt";
            if (m == "BANK" || m == "CARD" || m == "QR" || m == "E_WALLET") return "Chuyển khoản/Thẻ";

            return m; // Trường hợp khác trả về nguyên gốc
        }

        // 1. LOAD DANH SÁCH (SỬA SQL SUBQUERY)
        private void BindGrid(int pageIndex = 1)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string whereClause = "1=1";

                // Filter Tìm kiếm
                if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                    whereClause += " AND (u.full_name LIKE @s OR u.phone LIKE @s OR CAST(o.order_id AS NVARCHAR) LIKE @s)";

                // Filter Trạng thái
                if (!string.IsNullOrEmpty(ddlStatusFilter.SelectedValue))
                    whereClause += " AND o.status = @st";

                // Filter Thanh toán (Dùng Subquery vì orders không có cột payment_method)
                if (!string.IsNullOrEmpty(ddlPaymentFilter.SelectedValue))
                {
                    // Chú ý: Value lọc là CASH hoặc CARD
                    if (ddlPaymentFilter.SelectedValue == "CASH")
                        whereClause += " AND (SELECT TOP 1 method FROM payments p WHERE p.order_id = o.order_id) IN ('CASH', 'COD')";
                    else
                        whereClause += " AND (SELECT TOP 1 method FROM payments p WHERE p.order_id = o.order_id) IN ('CARD', 'BANK', 'QR', 'E_WALLET')";
                }

                // CÂU SQL CHÍNH (SỬA LỖI Invalid Column)
                // Lấy method từ bảng payments và đặt tên giả là payment_method
                string sql = $@"
                    SELECT o.order_id, o.total_amount, o.status, o.created_at, o.payment_status,
                           u.full_name, u.phone,
                           (SELECT TOP 1 method FROM payments p WHERE p.order_id = o.order_id) as payment_method
                    FROM orders o
                    LEFT JOIN users u ON o.customer_id = u.user_id
                    WHERE {whereClause}
                    ORDER BY o.created_at DESC
                    OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY;
                    
                    SELECT COUNT(*) FROM orders o LEFT JOIN users u ON o.customer_id = u.user_id WHERE {whereClause};
                ";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                        cmd.Parameters.AddWithValue("@s", "%" + txtSearch.Text.Trim() + "%");

                    if (!string.IsNullOrEmpty(ddlStatusFilter.SelectedValue))
                        cmd.Parameters.AddWithValue("@st", ddlStatusFilter.SelectedValue);

                    cmd.Parameters.AddWithValue("@skip", (pageIndex - 1) * pageSize);
                    cmd.Parameters.AddWithValue("@take", pageSize);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        rptOrders.DataSource = ds.Tables[0];
                        rptOrders.DataBind();

                        divNoData.Visible = ds.Tables[0].Rows.Count == 0;

                        int totalRows = Convert.ToInt32(ds.Tables[1].Rows[0][0]);
                        RenderPagination(totalRows, pageIndex);
                    }
                }
            }
        }

        private void RenderPagination(int totalRows, int currentPage)
        {
            int totalPages = (int)Math.Ceiling((double)totalRows / pageSize);
            StringBuilder sb = new StringBuilder();
            if (totalPages > 1)
            {
                for (int i = 1; i <= totalPages; i++)
                {
                    string activeClass = (i == currentPage) ? "active" : "";
                    sb.Append($"<a href='javascript:__doPostBack(\"PageChange\",\"{i}\")' class='page-item {activeClass}'>{i}</a>");
                }
            }
            litPagination.Text = sb.ToString();
        }

        protected override void RaisePostBackEvent(IPostBackEventHandler sourceControl, string eventArgument)
        {
            base.RaisePostBackEvent(sourceControl, eventArgument);
            if (Request["__EVENTTARGET"] == "PageChange")
            {
                int page = int.Parse(Request["__EVENTARGUMENT"]);
                BindGrid(page);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindGrid(1);
        }

        protected void rptOrders_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int orderId = Convert.ToInt32(e.CommandArgument);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                if (e.CommandName == "ViewOrder")
                {
                    string sqlOrder = @"SELECT o.*, u.full_name, u.phone 
                                        FROM orders o 
                                        LEFT JOIN users u ON o.customer_id = u.user_id 
                                        WHERE o.order_id = @id";

                    // Chưa có địa chỉ trong schema user/orders, lấy tạm tên user
                    string sqlItems = @"SELECT oi.*, d.dish_name, (oi.quantity * oi.unit_price) as total_price
                                        FROM order_items oi
                                        JOIN dishes d ON oi.dish_id = d.dish_id
                                        WHERE oi.order_id = @id";

                    using (SqlCommand cmd = new SqlCommand(sqlOrder, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", orderId);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                litViewOrderId.Text = r["order_id"].ToString();
                                litViewDate.Text = Convert.ToDateTime(r["created_at"]).ToString("dd/MM/yyyy HH:mm");
                                litViewCustomer.Text = $"{r["full_name"]} - {r["phone"]}";
                                litViewAddress.Text = "Tại nhà hàng (Dữ liệu mẫu)";
                                // Nếu có bảng address riêng thì join thêm vào query
                                litViewTotal.Text = Convert.ToDecimal(r["total_amount"]).ToString("N0") + " đ";
                            }
                        }
                    }

                    using (SqlCommand cmd = new SqlCommand(sqlItems, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", orderId);
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);
                            rptOrderItems.DataSource = dt;
                            rptOrderItems.DataBind();
                        }
                    }

                    string script = "setTimeout(function() { showViewModal(); }, 100);";
                    ClientScript.RegisterStartupScript(this.GetType(), "PopView", script, true);
                }
                else if (e.CommandName == "EditStatus")
                {
                    string sql = "SELECT status FROM orders WHERE order_id = @id";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", orderId);
                        object status = cmd.ExecuteScalar();
                        if (status != null)
                        {
                            hdfEditOrderId.Value = orderId.ToString();
                            ddlEditStatus.SelectedValue = status.ToString();

                            string script = "setTimeout(function() { showStatusModal(); }, 100);";
                            ClientScript.RegisterStartupScript(this.GetType(), "PopStatus", script, true);
                        }
                    }
                }
            }
        }

        protected void btnSaveStatus_Click(object sender, EventArgs e)
        {
            int orderId = int.Parse(hdfEditOrderId.Value);
            string newStatus = ddlEditStatus.SelectedValue;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = "UPDATE orders SET status = @st, updated_at = GETDATE() WHERE order_id = @id";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@st", newStatus);
                    cmd.Parameters.AddWithValue("@id", orderId);
                    cmd.ExecuteNonQuery();
                }
            }
            BindGrid();
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Orders.csv");
            Response.Charset = "utf-8";
            Response.ContentType = "application/text";
            Response.ContentEncoding = System.Text.Encoding.Unicode;
            Response.BinaryWrite(System.Text.Encoding.Unicode.GetPreamble());

            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Mã Đơn\tKhách Hàng\tSĐT\tTổng Tiền\tPTTT\tTrạng Thái\tNgày Đặt");

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                // Sửa query Export tương tự Grid
                string sql = @"
                    SELECT o.order_id, u.full_name, u.phone, o.total_amount, o.status, o.created_at,
                           (SELECT TOP 1 method FROM payments p WHERE p.order_id = o.order_id) as payment_method
                    FROM orders o 
                    LEFT JOIN users u ON o.customer_id = u.user_id 
                    ORDER BY o.order_id DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        string pMethod = r["payment_method"] != DBNull.Value ? r["payment_method"].ToString() : "Chưa TT";
                        sb.AppendLine($"{r["order_id"]}\t{r["full_name"]}\t{r["phone"]}\t{r["total_amount"]}\t{pMethod}\t{r["status"]}\t{r["created_at"]}");
                    }
                }
            }
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }
    }
}