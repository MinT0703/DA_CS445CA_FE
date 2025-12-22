using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace BestFoodRestaurant.Pages.Customer
{
    public partial class Register : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["CustomerID"] != null)
            {
                Response.Redirect("Default.aspx");
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;

            string fullName = txtFullName.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string pass = txtPassword.Text;

            // Các trường này DB chưa có cột, tạm thời lấy nhưng chưa lưu
            string dob = txtDob.Text;
            string address = txtAddress.Text;

            // Xử lý Upload Avatar (nếu cần thiết sau này)
            /*
            if (fuAvatar.HasFile) {
                string fileName = System.IO.Path.GetFileName(fuAvatar.FileName);
                fuAvatar.SaveAs(Server.MapPath("~/Uploads/" + fileName));
            }
            */

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                try
                {
                    conn.Open();

                    // 1. Kiểm tra SĐT đã tồn tại chưa
                    string checkSql = "SELECT COUNT(*) FROM users WHERE phone = @phone";
                    using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@phone", phone);
                        int exists = (int)checkCmd.ExecuteScalar();
                        if (exists > 0)
                        {
                            ShowMessage("Số điện thoại này đã được đăng ký.", false);
                            return;
                        }
                    }

                    // 2. Thêm mới user
                    // Mặc định role_id = 1 (Khách hàng), status = 'ACTIVE'
                    // Lưu ý: Mật khẩu nên được Hash (Mã hóa) trước khi lưu. Ở đây lưu plaintext để demo cho khớp với Login.
                    string insertSql = @"INSERT INTO users (full_name, phone, password_hash, role_id, status, created_at) 
                                         VALUES (@name, @phone, @pass, 1, 'ACTIVE', GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(insertSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@name", fullName);
                        cmd.Parameters.AddWithValue("@phone", phone);
                        cmd.Parameters.AddWithValue("@pass", pass); // Nên dùng SHA256/BCrypt ở đây

                        cmd.ExecuteNonQuery();
                    }

                    // Đăng ký thành công -> Chuyển sang đăng nhập
                    string script = "alert('Đăng ký thành công! Vui lòng đăng nhập.'); window.location='Login.aspx';";
                    ScriptManager.RegisterStartupScript(this, GetType(), "RegSuccess", script, true);
                }
                catch (Exception ex)
                {
                    ShowMessage("Lỗi hệ thống: " + ex.Message, false);
                }
            }
        }

        private void ShowMessage(string msg, bool isSuccess)
        {
            lblMessage.Text = msg;
            pnlMessage.CssClass = isSuccess ? "alert-box alert-success" : "alert-box alert-error";
            pnlMessage.Visible = true;
        }
    }
}