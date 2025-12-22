using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BestFoodRestaurant.Pages.Customer
{
    public partial class AccountDetail : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;
        int customerId = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }
            customerId = Convert.ToInt32(Session["CustomerID"]);

            if (!IsPostBack)
            {
                LoadUserProfile();
                LoadOrderHistory();
            }
        }

        private void LoadUserProfile()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT full_name, phone, email FROM users WHERE user_id = @uid";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", customerId);
                    conn.Open();
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string name = r["full_name"].ToString();
                            txtFullName.Text = name;
                            litSidebarName.Text = name;
                            txtPhone.Text = r["phone"].ToString();
                            txtEmail.Text = r["email"].ToString();
                        }
                    }
                }
            }
        }

        private void LoadOrderHistory()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Join order_items để đếm số món (item_count)
                string sql = @"
                    SELECT o.order_id, o.order_time, o.total_amount, o.status, COUNT(oi.order_item_id) as item_count 
                    FROM orders o
                    LEFT JOIN order_items oi ON o.order_id = oi.order_id
                    WHERE o.customer_id = @uid
                    GROUP BY o.order_id, o.order_time, o.total_amount, o.status
                    ORDER BY o.order_time DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", customerId);
                    conn.Open();
                    rptOrders.DataSource = cmd.ExecuteReader();
                    rptOrders.DataBind();
                }
            }
        }

        protected void SwitchTab_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string viewName = btn.CommandArgument;

            // Reset CSS Active
            btnNavProfile.CssClass = "nav-btn";
            btnNavOrders.CssClass = "nav-btn";
            btnNavPassword.CssClass = "nav-btn";

            // Set Active
            btn.CssClass = "nav-btn active";

            if (viewName == "Profile") mvAccount.ActiveViewIndex = 0;
            else if (viewName == "Orders") mvAccount.ActiveViewIndex = 1;
            else if (viewName == "Password") mvAccount.ActiveViewIndex = 2;

            pnlMessage.Visible = false;
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "UPDATE users SET full_name = @name, email = @email WHERE user_id = @uid";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@name", txtFullName.Text.Trim());
                    cmd.Parameters.AddWithValue("@email", txtEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@uid", customerId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            // Cập nhật lại Session tên hiển thị
            Session["CustomerName"] = txtFullName.Text.Trim();
            ShowMessage("Cập nhật thông tin thành công!", true);

            // Refresh lại tên bên sidebar
            litSidebarName.Text = txtFullName.Text.Trim();
        }

        protected void btnChangePass_Click(object sender, EventArgs e)
        {
            string oldPass = txtOldPass.Text;
            string newPass = txtNewPass.Text;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 1. Check mật khẩu cũ
                // Lưu ý: Nếu DB lưu hash thì phải hash oldPass trước khi so sánh
                string sqlCheck = "SELECT COUNT(*) FROM users WHERE user_id = @uid AND password_hash = @old";
                using (SqlCommand cmd = new SqlCommand(sqlCheck, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", customerId);
                    cmd.Parameters.AddWithValue("@old", oldPass); // Demo plaintext
                    int count = (int)cmd.ExecuteScalar();

                    if (count == 0)
                    {
                        ShowMessage("Mật khẩu hiện tại không đúng.", false);
                        return;
                    }
                }

                // 2. Cập nhật mật khẩu mới
                string sqlUpdate = "UPDATE users SET password_hash = @new WHERE user_id = @uid";
                using (SqlCommand cmdUpdate = new SqlCommand(sqlUpdate, conn))
                {
                    cmdUpdate.Parameters.AddWithValue("@new", newPass); // Demo plaintext (Nên dùng SHA256)
                    cmdUpdate.Parameters.AddWithValue("@uid", customerId);
                    cmdUpdate.ExecuteNonQuery();
                }
            }

            ShowMessage("Đổi mật khẩu thành công!", true);
            txtOldPass.Text = "";
            txtNewPass.Text = "";
            txtConfirmPass.Text = "";
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = msg;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "alert-success" : "alert-danger";
        }
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Xóa toàn bộ Session
            Session.RemoveAll();
            Session.Abandon();

            // Chuyển hướng về trang Đăng nhập
            Response.Redirect("Login.aspx");
        }
    }
}