using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BestFoodRestaurant.Pages.Admin
{
    public partial class Promos : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        // --- HELPERS HIỂN THỊ ---
        public string FormatDiscount(object typeObj, object valObj)
        {
            if (typeObj == null || valObj == null) return "";
            string type = typeObj.ToString();
            decimal val = Convert.ToDecimal(valObj);

            if (type == "PERCENT") return $"-{val:0.#}%";
            return $"-{val:N0} đ";
        }

        public string GetStatusBadge(object activeObj, object endDateObj)
        {
            bool isActive = Convert.ToBoolean(activeObj);
            DateTime endDate = Convert.ToDateTime(endDateObj);

            if (!isActive) return "<span class='status-inactive'>Đã tắt</span>";
            if (endDate < DateTime.Now) return "<span class='status-expired'>Hết hạn</span>";

            return "<span class='status-active'>Đang chạy</span>";
        }

        // --- DATA BINDING ---
        private void BindGrid()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string whereClause = "1=1";

                // Tìm kiếm theo Code
                if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                    whereClause += " AND code LIKE @s";

                // Lọc trạng thái
                string filter = ddlStatusFilter.SelectedValue;
                if (filter == "1") whereClause += " AND is_active = 1 AND end_date >= GETDATE()";
                else if (filter == "0") whereClause += " AND is_active = 0";
                else if (filter == "EXPIRED") whereClause += " AND end_date < GETDATE()";

                string sql = $"SELECT * FROM promotions WHERE {whereClause} ORDER BY created_at DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                        cmd.Parameters.AddWithValue("@s", "%" + txtSearch.Text.Trim() + "%");

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptPromos.DataSource = dt;
                        rptPromos.DataBind();
                        divNoData.Visible = dt.Rows.Count == 0;
                    }
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindGrid();
        }

        // --- CRUD OPERATIONS ---
        protected void btnSave_Click(object sender, EventArgs e)
        {
            string promoId = hdfPromoId.Value;
            string code = txtCode.Text.Trim().ToUpper();
            string desc = txtDesc.Text.Trim();
            string type = ddlType.SelectedValue;
            decimal val = decimal.Parse(txtValue.Text);
            decimal minOrder = string.IsNullOrEmpty(txtMinOrder.Text) ? 0 : decimal.Parse(txtMinOrder.Text);
            DateTime start = DateTime.Parse(txtStartDate.Text);
            DateTime end = DateTime.Parse(txtEndDate.Text);
            bool isActive = ddlActive.SelectedValue == "1";

            if (string.IsNullOrEmpty(code)) return;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql;

                if (string.IsNullOrEmpty(promoId))
                {
                    // INSERT (Kiểm tra trùng code)
                    string checkSql = "SELECT COUNT(*) FROM promotions WHERE code = @code";
                    using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@code", code);
                        if ((int)checkCmd.ExecuteScalar() > 0)
                        {
                            ClientScript.RegisterStartupScript(this.GetType(), "Alert", "alert('Mã Code này đã tồn tại!');", true);
                            return;
                        }
                    }

                    sql = @"INSERT INTO promotions (code, description, discount_type, discount_value, min_order_value, start_date, end_date, is_active) 
                            VALUES (@c, @d, @t, @v, @m, @s, @e, @a)";
                }
                else
                {
                    // UPDATE
                    sql = @"UPDATE promotions SET code=@c, description=@d, discount_type=@t, discount_value=@v, 
                            min_order_value=@m, start_date=@s, end_date=@e, is_active=@a WHERE promo_id=@id";
                }

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@c", code);
                    cmd.Parameters.AddWithValue("@d", desc);
                    cmd.Parameters.AddWithValue("@t", type);
                    cmd.Parameters.AddWithValue("@v", val);
                    cmd.Parameters.AddWithValue("@m", minOrder);
                    cmd.Parameters.AddWithValue("@s", start);
                    cmd.Parameters.AddWithValue("@e", end);
                    cmd.Parameters.AddWithValue("@a", isActive);

                    if (!string.IsNullOrEmpty(promoId))
                        cmd.Parameters.AddWithValue("@id", promoId);

                    cmd.ExecuteNonQuery();
                }
            }
            BindGrid();
        }

        protected void rptPromos_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                if (e.CommandName == "EditPromo")
                {
                    string sql = "SELECT * FROM promotions WHERE promo_id = @id";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                hdfPromoId.Value = r["promo_id"].ToString();
                                txtCode.Text = r["code"].ToString();
                                txtDesc.Text = r["description"].ToString();
                                ddlType.SelectedValue = r["discount_type"].ToString();
                                txtValue.Text = Convert.ToDecimal(r["discount_value"]).ToString("0.##"); // Bỏ số 0 thừa
                                txtMinOrder.Text = Convert.ToDecimal(r["min_order_value"]).ToString("F0");

                                // Format date for HTML5 Date Input (yyyy-MM-dd)
                                txtStartDate.Text = Convert.ToDateTime(r["start_date"]).ToString("yyyy-MM-dd");
                                txtEndDate.Text = Convert.ToDateTime(r["end_date"]).ToString("yyyy-MM-dd");

                                ddlActive.SelectedValue = Convert.ToBoolean(r["is_active"]) ? "1" : "0";

                                string script = "setTimeout(function() { showEditModal(); }, 100);";
                                ClientScript.RegisterStartupScript(this.GetType(), "PopPromo", script, true);
                            }
                        }
                    }
                }
                else if (e.CommandName == "DeletePromo")
                {
                    string sql = "DELETE FROM promotions WHERE promo_id = @id";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.ExecuteNonQuery();
                    }
                    BindGrid();
                }
            }
        }
    }
}