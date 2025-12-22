using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace BestFoodRestaurant.Pages.Customer
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Nếu đã đăng nhập thì không cần vào trang này
            if (Session["CustomerID"] != null)
            {
                Response.Redirect("Default.aspx");
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;

            string identity = txtIdentity.Text.Trim();

            // Kiểm tra xem Email/SĐT có tồn tại trong Database không
            if (CheckUserExists(identity))
            {
                // TRƯỜNG HỢP THỰC TẾ: Sinh mã token, lưu vào DB và gửi Email/SMS thật.
                // TRƯỜNG HỢP DEMO: Thông báo thành công giả lập.

                ShowMessage("Hệ thống đã gửi liên kết đặt lại mật khẩu đến: <b>" + identity + "</b>. (Mô phỏng)", true);

                // Ẩn nút gửi để tránh spam
                btnSubmit.Visible = false;
                txtIdentity.Enabled = false;
            }
            else
            {
                ShowMessage("Thông tin không tồn tại trong hệ thống.", false);
            }
        }

        private bool CheckUserExists(string identity)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT COUNT(*) FROM users WHERE (email = @id OR phone = @id) AND status = 'ACTIVE'";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", identity);
                    try
                    {
                        conn.Open();
                        int count = (int)cmd.ExecuteScalar();
                        return count > 0;
                    }
                    catch
                    {
                        return false;
                    }
                }
            }
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = msg;
            pnlMessage.CssClass = success ? "alert-box alert-success" : "alert-box alert-error";
            pnlMessage.Visible = true;
        }
    }
}