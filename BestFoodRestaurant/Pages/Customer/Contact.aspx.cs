using System;
using System.Web.UI;

namespace BestFoodRestaurant.Pages.Customer
{
    public partial class Contact : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Nếu người dùng đã đăng nhập, tự động điền thông tin vào form
            if (!IsPostBack && Session["CustomerID"] != null)
            {
                if (Session["CustomerName"] != null) txtName.Text = Session["CustomerName"].ToString();
                if (Session["CustomerPhone"] != null) txtPhone.Text = Session["CustomerPhone"].ToString();
                // Nếu có email trong session thì điền luôn, ở đây demo nên thôi
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            if (IsValid)
            {
                // Ở đây bạn sẽ viết code gửi Email (SMTP) hoặc lưu vào DB
                // Ví dụ: MailService.Send(txtEmail.Text, "Admin", "Liên hệ mới", txtMessage.Text);

                // Demo: Hiển thị thông báo thành công
                pnlSuccess.Visible = true;

                // Reset form
                txtMessage.Text = "";
                ddlSubject.SelectedIndex = 0;
            }
        }
    }
}