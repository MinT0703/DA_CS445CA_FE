using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BestFoodRestaurant.Pages.Customer
{
    public partial class Menu : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCategories();
                LoadDishes();
            }
        }

        private void LoadCategories()
        {
            if (string.IsNullOrEmpty(connStr)) return;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT category_id, category_name FROM menu_categories WHERE is_active = 1";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    rptCategories.DataSource = cmd.ExecuteReader();
                    rptCategories.DataBind();
                }
            }
        }

        private void LoadDishes()
        {
            if (string.IsNullOrEmpty(connStr)) return;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Base Query
                string sql = @"SELECT dish_id, dish_name, description, price, image_url 
                               FROM dishes 
                               WHERE is_available = 1";

                // Filter by Category
                int catId = 0;
                if (ViewState["CurrentCat"] != null)
                {
                    catId = (int)ViewState["CurrentCat"];
                    if (catId > 0)
                    {
                        sql += " AND category_id = @catId";
                    }
                }

                // Filter by Search
                string search = txtSearch.Text.Trim();
                if (!string.IsNullOrEmpty(search))
                {
                    sql += " AND (dish_name LIKE @search OR description LIKE @search)";
                }

                // Sort
                string sort = ddlSort.SelectedValue;
                switch (sort)
                {
                    case "price_asc": sql += " ORDER BY price ASC"; break;
                    case "price_desc": sql += " ORDER BY price DESC"; break;
                    case "name_asc": sql += " ORDER BY dish_name ASC"; break;
                    default: sql += " ORDER BY created_at DESC"; break; // newest
                }

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (catId > 0) cmd.Parameters.AddWithValue("@catId", catId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@search", "%" + search + "%");

                    conn.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptDishes.DataSource = dt;
                    rptDishes.DataBind();

                    lblNoData.Visible = (dt.Rows.Count == 0);
                }
            }

            // Cập nhật CSS Active cho category pills
            UpdateActiveCategoryStyle();
        }

        protected void FilterCategory_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            int catId = int.Parse(btn.CommandArgument);
            ViewState["CurrentCat"] = catId;
            LoadDishes();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            LoadDishes();
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDishes();
        }

        private void UpdateActiveCategoryStyle()
        {
            int currentCat = ViewState["CurrentCat"] != null ? (int)ViewState["CurrentCat"] : 0;

            // Xử lý nút "Tất cả"
            if (currentCat == 0) lnkAll.CssClass = "pill-btn active";
            else lnkAll.CssClass = "pill-btn";

            // Xử lý các nút trong Repeater
            foreach (RepeaterItem item in rptCategories.Items)
            {
                LinkButton lnk = (LinkButton)item.FindControl("lnkCat");
                if (lnk != null)
                {
                    int id = int.Parse(lnk.CommandArgument);
                    if (id == currentCat) lnk.CssClass = "pill-btn active";
                    else lnk.CssClass = "pill-btn";
                }
            }
        }
    }
}