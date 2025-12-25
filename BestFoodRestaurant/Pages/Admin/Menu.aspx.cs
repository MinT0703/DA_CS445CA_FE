using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BestFoodRestaurant.Pages.Admin
{
    public partial class Menu : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;
        int pageSize = 10;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCategories();
                BindGrid();
            }
        }

        // 1. LOAD DANH MỤC (SỬA: Dùng bảng menu_categories)
        private void LoadCategories()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Lưu ý: Đảm bảo bảng menu_categories có cột category_id và category_name
                // Nếu cột tên khác (ví dụ 'name'), hãy sửa lại trong câu SQL này
                string sql = "SELECT category_id, category_name FROM menu_categories ORDER BY category_name";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    try
                    {
                        conn.Open();
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            DataTable dt = new DataTable();
                            dt.Load(r);

                            // 1. Dropdown Filter
                            ddlCategoryFilter.DataSource = dt;
                            ddlCategoryFilter.DataTextField = "category_name";
                            ddlCategoryFilter.DataValueField = "category_id";
                            ddlCategoryFilter.DataBind();
                            ddlCategoryFilter.Items.Insert(0, new ListItem("-- Tất cả danh mục --", ""));

                            // 2. Dropdown Modal
                            ddlCategory.DataSource = dt;
                            ddlCategory.DataTextField = "category_name";
                            ddlCategory.DataValueField = "category_id";
                            ddlCategory.DataBind();
                        }
                    }
                    catch (Exception ex)
                    {
                        // Nếu lỗi cột không tồn tại, hiện thông báo để debug
                        ClientScript.RegisterStartupScript(this.GetType(), "Error", $"alert('Lỗi lấy danh mục: {ex.Message}');", true);
                    }
                }
            }
        }

        // 2. LOAD LƯỚI DỮ LIỆU (SỬA: Join với menu_categories)
        private void BindGrid(int pageIndex = 1)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string whereClause = "1=1";

                if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                    whereClause += " AND (d.dish_name LIKE @s OR d.description LIKE @s)";

                if (!string.IsNullOrEmpty(ddlCategoryFilter.SelectedValue))
                    whereClause += " AND d.category_id = @c";

                if (!string.IsNullOrEmpty(ddlStatusFilter.SelectedValue))
                    whereClause += " AND d.is_available = @st";

                // SỬA: LEFT JOIN menu_categories
                string sql = $@"
                    SELECT d.*, c.category_name 
                    FROM dishes d
                    LEFT JOIN menu_categories c ON d.category_id = c.category_id
                    WHERE {whereClause}
                    ORDER BY d.created_at DESC
                    OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY;
                    
                    SELECT COUNT(*) FROM dishes d WHERE {whereClause};
                ";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                        cmd.Parameters.AddWithValue("@s", "%" + txtSearch.Text.Trim() + "%");

                    if (!string.IsNullOrEmpty(ddlCategoryFilter.SelectedValue))
                        cmd.Parameters.AddWithValue("@c", ddlCategoryFilter.SelectedValue);

                    if (!string.IsNullOrEmpty(ddlStatusFilter.SelectedValue))
                        cmd.Parameters.AddWithValue("@st", ddlStatusFilter.SelectedValue);

                    cmd.Parameters.AddWithValue("@skip", (pageIndex - 1) * pageSize);
                    cmd.Parameters.AddWithValue("@take", pageSize);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        rptDishes.DataSource = ds.Tables[0];
                        rptDishes.DataBind();

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

        // 3. XỬ LÝ LƯU
        protected void btnSave_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            string priceStr = txtPrice.Text.Trim();
            string desc = txtDescription.Text.Trim();
            string catId = ddlCategory.SelectedValue;
            string status = ddlStatus.SelectedValue;
            string dishId = hdfDishId.Value;

            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(priceStr)) return;

            decimal price = decimal.Parse(priceStr);
            string imagePath = hdfOldImage.Value;

            if (fileImage.HasFile)
            {
                try
                {
                    string fileName = DateTime.Now.Ticks + "_" + fileImage.FileName;
                    string folderPath = Server.MapPath("~/Assets/images/dishes/");
                    if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath);
                    fileImage.SaveAs(folderPath + fileName);
                    imagePath = "/Assets/images/dishes/" + fileName;
                }
                catch { }
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = "";

                if (string.IsNullOrEmpty(dishId))
                {
                    sql = "INSERT INTO dishes (dish_name, category_id, price, description, is_available, image_url, created_at) VALUES (@n, @c, @p, @d, @st, @img, GETDATE())";
                }
                else
                {
                    sql = "UPDATE dishes SET dish_name=@n, category_id=@c, price=@p, description=@d, is_available=@st, image_url=@img WHERE dish_id=@id";
                }

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@n", name);
                    cmd.Parameters.AddWithValue("@c", catId);
                    cmd.Parameters.AddWithValue("@p", price);
                    cmd.Parameters.AddWithValue("@d", desc);
                    cmd.Parameters.AddWithValue("@st", status);
                    cmd.Parameters.AddWithValue("@img", imagePath ?? (object)DBNull.Value);

                    if (!string.IsNullOrEmpty(dishId))
                        cmd.Parameters.AddWithValue("@id", dishId);

                    cmd.ExecuteNonQuery();
                }
            }
            BindGrid();
        }

        protected void rptDishes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int dishId = Convert.ToInt32(e.CommandArgument);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                if (e.CommandName == "EditDish")
                {
                    string sql = "SELECT * FROM dishes WHERE dish_id = @id";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", dishId);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                hdfDishId.Value = r["dish_id"].ToString();
                                txtName.Text = r["dish_name"].ToString();
                                txtPrice.Text = Convert.ToDecimal(r["price"]).ToString("F0");
                                txtDescription.Text = r["description"].ToString();
                                ddlCategory.SelectedValue = r["category_id"].ToString();
                                ddlStatus.SelectedValue = Convert.ToBoolean(r["is_available"]) ? "1" : "0";
                                hdfOldImage.Value = r["image_url"].ToString();

                                string script = "setTimeout(function() { showEditModal(); }, 100);";
                                ClientScript.RegisterStartupScript(this.GetType(), "Pop", script, true);
                            }
                        }
                    }
                }
                else if (e.CommandName == "DeleteDish")
                {
                    try
                    {
                        string sql = "DELETE FROM dishes WHERE dish_id = @id";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@id", dishId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    catch
                    {
                        string sqlSoft = "UPDATE dishes SET is_available = 0 WHERE dish_id = @id";
                        using (SqlCommand cmd = new SqlCommand(sqlSoft, conn))
                        {
                            cmd.Parameters.AddWithValue("@id", dishId);
                            cmd.ExecuteNonQuery();
                        }
                        ClientScript.RegisterStartupScript(this.GetType(), "Alert", "alert('Món này đang được sử dụng nên không thể xóa. Đã chuyển sang trạng thái NGỪNG BÁN.');", true);
                    }
                    BindGrid();
                }
                else if (e.CommandName == "ToggleStatus")
                {
                    string sql = "UPDATE dishes SET is_available = CASE WHEN is_available = 1 THEN 0 ELSE 1 END WHERE dish_id = @id";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", dishId);
                        cmd.ExecuteNonQuery();
                    }
                    BindGrid();
                }
            }
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            // Logic Export CSV nếu cần
        }
    }
}