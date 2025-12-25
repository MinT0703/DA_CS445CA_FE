using System;
using System.Web;
using System.Web.UI;

namespace BestFoodRestaurant.MasterPages
{
    public partial class Admin : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Kiểm tra Session đăng nhập
            if (Session["CustomerID"] == null || Session["RoleID"] == null)
            {
                Response.Redirect("~/Pages/Customer/Login.aspx");
                return;
            }

            // Kiểm tra quyền Admin
            string roleId = Session["RoleID"].ToString();
            if (roleId != "5")
            {
                Response.Redirect("~/Pages/Customer/Default.aspx");
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            // Xóa Session
            Session.Clear();
            Session.Abandon();

            // Chuyển hướng về trang chủ
            Response.Redirect("~/Pages/Customer/Default.aspx");
        }
    }
}