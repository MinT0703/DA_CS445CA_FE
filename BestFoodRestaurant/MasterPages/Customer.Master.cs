using System;
using System.Web;
using System.Web.UI;

namespace BestFoodRestaurant.MasterPages
{
    public partial class Customer : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CheckLoginStatus();
            }
        }

        private void CheckLoginStatus()
        {
            // Kiểm tra session
            if (Session["CustomerID"] != null)
            {
                // Đã đăng nhập
                lnkLogin.Visible = false;
                lnkRegister.Visible = false;
                pnlLoggedIn.Visible = true;

            }
            else
            {
                // Chưa đăng nhập
                lnkLogin.Visible = true;
                lnkRegister.Visible = true;
                pnlLoggedIn.Visible = false;
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            // Xóa Session
            Session.RemoveAll();
            Session.Abandon();

            // Xóa Cookie Ghi nhớ (quan trọng)
            if (Request.Cookies["BestFoodLogin"] != null)
            {
                HttpCookie myCookie = new HttpCookie("BestFoodLogin");
                myCookie.Expires = DateTime.Now.AddDays(-1d); // Đặt ngày hết hạn về quá khứ
                Response.Cookies.Add(myCookie);
            }

            // Chuyển hướng
            Response.Redirect("~/Pages/Customer/Default.aspx");
        }

        protected void btnSubscribe_Click(object sender, EventArgs e)
        {
            // Xử lý đăng ký newsletter
            string email = txtNewsletter.Text.Trim();

            if (!string.IsNullOrEmpty(email))
            {
                // TODO: Lưu email vào database
                // Tạm thời hiển thị thông báo
                ScriptManager.RegisterStartupScript(this, GetType(), "NewsletterSuccess",
                    "alert('Cảm ơn bạn đã đăng ký nhận bản tin!');", true);
                txtNewsletter.Text = "";
            }
        }
    }
}