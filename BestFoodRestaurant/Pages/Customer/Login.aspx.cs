using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace BestFoodRestaurant.Pages.Customer
{
    public partial class Login : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // 1. Nếu đã có Session (đang đăng nhập)
                if (Session["CustomerID"] != null)
                {
                    RedirectUserBasedOnRole();
                }
                // 2. Nếu chưa có Session, kiểm tra Cookie "Ghi nhớ"
                else
                {
                    CheckRememberCookie();
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;

            string identity = txtIdentity.Text.Trim();
            string password = txtPassword.Text;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Tìm user theo Email hoặc SĐT
                string sql = "SELECT user_id, full_name, phone, email, password_hash, role_id FROM users WHERE (email = @id OR phone = @id) AND status = 'ACTIVE'";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", identity);

                    try
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string dbPassHash = reader["password_hash"].ToString();

                                // Kiểm tra mật khẩu
                                if (password == dbPassHash)
                                {
                                    // 1. Lưu thông tin vào Session
                                    SetUserSession(reader);

                                    // 2. Xử lý "Ghi nhớ tôi"
                                    if (chkRemember.Checked)
                                    {
                                        HttpCookie cookie = new HttpCookie("BestFoodLogin");
                                        cookie.Values["UserID"] = reader["user_id"].ToString();
                                        cookie.Expires = DateTime.Now.AddDays(30);
                                        Response.Cookies.Add(cookie);
                                    }

                                    // 3. Chuyển hướng
                                    RedirectUserBasedOnRole();
                                }
                                else
                                {
                                    ShowError("Mật khẩu không chính xác.");
                                }
                            }
                            else
                            {
                                ShowError("Tài khoản không tồn tại hoặc đã bị khóa.");
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowError("Lỗi hệ thống: " + ex.Message);
                    }
                }
            }
        }

        // Hàm kiểm tra Cookie khi tải trang
        private void CheckRememberCookie()
        {
            HttpCookie cookie = Request.Cookies["BestFoodLogin"];
            if (cookie != null && !string.IsNullOrEmpty(cookie.Values["UserID"]))
            {
                string userId = cookie.Values["UserID"];

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = "SELECT user_id, full_name, phone, email, role_id FROM users WHERE user_id = @uid AND status = 'ACTIVE'";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        try
                        {
                            conn.Open();
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    SetUserSession(reader);
                                    RedirectUserBasedOnRole();
                                }
                            }
                        }
                        catch { /* Bỏ qua lỗi cookie cũ/sai */ }
                    }
                }
            }
        }

        // Hàm điều hướng tập trung (Dùng chung cho cả Login, PageLoad, Cookie)
        private void RedirectUserBasedOnRole()
        {
            // Lấy RoleID từ Session (đã được set trước đó)
            string roleId = Session["RoleID"] != null ? Session["RoleID"].ToString() : "";

            if (roleId == "5") // ADMIN
            {
                Response.Redirect("~/Pages/Admin/Dashboard.aspx", false);
                // dùng false để tránh lỗi ThreadAbortException
                Context.ApplicationInstance.CompleteRequest();
            }
            else // KHÁCH HÀNG
            {
                Response.Redirect("~/Pages/Customer/Default.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        private void SetUserSession(SqlDataReader reader)
        {
            Session["CustomerID"] = reader["user_id"];
            Session["CustomerName"] = reader["full_name"];
            Session["CustomerPhone"] = reader["phone"];
            Session["RoleID"] = reader["role_id"];
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            pnlError.Visible = true;
        }
    }
}