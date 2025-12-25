using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BestFoodRestaurant.Pages.Admin
{
    public partial class Accounts : System.Web.UI.Page
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

        // --- HELPER METHODS CHO ROLE (Dựa vào ảnh bạn gửi) ---
        public string GetRoleName(object roleIdObj)
        {
            if (roleIdObj == null) return "Không xác định";
            string rid = roleIdObj.ToString();
            switch (rid)
            {
                case "5": return "Quản trị viên"; // Admin
                case "4": return "Quản lý";       // Manager
                case "3": return "Đầu bếp";       // Chef
                case "2": return "Nhân viên";     // Staff
                case "1": return "Khách hàng";    // Customer
                default: return "Khác";
            }
        }

        public string GetRoleBadgeClass(object roleIdObj)
        {
            if (roleIdObj == null) return "role-badge";
            string rid = roleIdObj.ToString();
            switch (rid)
            {
                case "5": return "role-badge role-admin";
                case "4": return "role-badge role-manager";
                case "3": return "role-badge role-chef";
                case "2": return "role-badge role-staff";
                case "1": return "role-badge role-customer";
                default: return "role-badge";
            }
        }

        // --- GRID BINDING ---
        private void BindGrid(int pageIndex = 1)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string whereClause = "1=1";
                if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                    whereClause += " AND (full_name LIKE @s OR email LIKE @s OR phone LIKE @s)";

                if (!string.IsNullOrEmpty(ddlRoleFilter.SelectedValue))
                    whereClause += " AND role_id = @r";

                string sql = $@"
                    SELECT * FROM users 
                    WHERE {whereClause}
                    ORDER BY created_at DESC 
                    OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY;
                    SELECT COUNT(*) FROM users WHERE {whereClause};
                ";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                        cmd.Parameters.AddWithValue("@s", "%" + txtSearch.Text.Trim() + "%");

                    if (!string.IsNullOrEmpty(ddlRoleFilter.SelectedValue))
                        cmd.Parameters.AddWithValue("@r", ddlRoleFilter.SelectedValue);

                    cmd.Parameters.AddWithValue("@skip", (pageIndex - 1) * pageSize);
                    cmd.Parameters.AddWithValue("@take", pageSize);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataSet ds = new DataSet();
                        da.Fill(ds);
                        rptUsers.DataSource = ds.Tables[0];
                        rptUsers.DataBind();
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

        // --- XỬ LÝ NÚT LỆNH ---
        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int userId = Convert.ToInt32(e.CommandArgument);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                if (e.CommandName == "EditUser")
                {
                    string sql = "SELECT * FROM users WHERE user_id = @uid";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                // Load dữ liệu vào control
                                hdfUserId.Value = r["user_id"].ToString();
                                txtName.Text = r["full_name"].ToString();
                                txtEmail.Text = r["email"].ToString();
                                txtPhone.Text = r["phone"].ToString();
                                ddlRole.SelectedValue = r["role_id"].ToString();

                                // Gửi lệnh JS xuống Client để mở modal
                                string script = "setTimeout(function() { showEditModal(); }, 100);";
                                ClientScript.RegisterStartupScript(this.GetType(), "OpenModal", script, true);
                            }
                        }
                    }
                }
                else if (e.CommandName == "DeleteUser")
                {
                    // QUY TRÌNH XÓA SẠCH (TRÁNH LỖI FK)
                    string sqlDelItems = "DELETE FROM order_items WHERE order_id IN (SELECT order_id FROM orders WHERE customer_id = @uid)";
                    string sqlDelOrders = "DELETE FROM orders WHERE customer_id = @uid";
                    string sqlDelReservations = "DELETE FROM reservations WHERE customer_id = @uid"; // <-- Quan trọng: Xóa đặt bàn
                    string sqlDelUser = "DELETE FROM users WHERE user_id = @uid";

                    using (SqlTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Xóa chi tiết đơn hàng
                            using (SqlCommand cmd = new SqlCommand(sqlDelItems, conn, trans)) { cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                            // 2. Xóa đơn hàng
                            using (SqlCommand cmd = new SqlCommand(sqlDelOrders, conn, trans)) { cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                            // 3. Xóa đặt bàn (Fix lỗi FK_reservations_customer)
                            using (SqlCommand cmd = new SqlCommand(sqlDelReservations, conn, trans)) { cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                            // 4. Xóa user
                            using (SqlCommand cmd = new SqlCommand(sqlDelUser, conn, trans)) { cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }

                            trans.Commit();
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            // Bạn có thể log lỗi tại đây
                        }
                    }
                    BindGrid();
                }
                else if (e.CommandName == "ToggleLock")
                {
                    string sql = "UPDATE users SET status = CASE WHEN status = 'ACTIVE' THEN 'LOCKED' ELSE 'ACTIVE' END WHERE user_id = @uid";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.ExecuteNonQuery();
                    }
                    BindGrid();
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string pass = txtPass.Text;
            int role = int.Parse(ddlRole.SelectedValue);
            string userId = hdfUserId.Value;

            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(email)) return;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = "";

                if (string.IsNullOrEmpty(userId))
                {
                    if (string.IsNullOrEmpty(pass)) pass = "123456";
                    sql = "INSERT INTO users (full_name, email, phone, password_hash, role_id, status, created_at) VALUES (@n, @e, @p, @pass, @r, 'ACTIVE', GETDATE())";
                }
                else
                {
                    if (string.IsNullOrEmpty(pass))
                        sql = "UPDATE users SET full_name=@n, email=@e, phone=@p, role_id=@r WHERE user_id=@uid";
                    else
                        sql = "UPDATE users SET full_name=@n, email=@e, phone=@p, role_id=@r, password_hash=@pass WHERE user_id=@uid";
                }

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@n", name);
                    cmd.Parameters.AddWithValue("@e", email);
                    cmd.Parameters.AddWithValue("@p", phone);
                    cmd.Parameters.AddWithValue("@r", role);
                    if (!string.IsNullOrEmpty(pass) || string.IsNullOrEmpty(userId))
                        cmd.Parameters.AddWithValue("@pass", pass);

                    if (!string.IsNullOrEmpty(userId))
                        cmd.Parameters.AddWithValue("@uid", userId);

                    cmd.ExecuteNonQuery();
                }
            }
            BindGrid();
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Accounts.csv");
            Response.Charset = "utf-8";
            Response.ContentType = "application/text";
            Response.ContentEncoding = System.Text.Encoding.Unicode;
            Response.BinaryWrite(System.Text.Encoding.Unicode.GetPreamble());

            StringBuilder sb = new StringBuilder();
            sb.AppendLine("ID\tHọ Tên\tEmail\tSĐT\tRoleID\tTrạng Thái\tNgày Tạo");
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = "SELECT * FROM users ORDER BY user_id DESC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        sb.AppendLine($"{r["user_id"]}\t{r["full_name"]}\t{r["email"]}\t{r["phone"]}\t{r["role_id"]}\t{r["status"]}\t{r["created_at"]}");
                    }
                }
            }
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }
    }
}