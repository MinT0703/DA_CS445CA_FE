using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization; // Cần thiết để tạo JSON cho biểu đồ
using System.Web.UI;

namespace BestFoodRestaurant.Pages.Admin
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardStats();
            }
        }

        private void LoadDashboardStats()
        {
            string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 1. KPI: TỔNG DOANH THU (30 ngày qua, chỉ tính đơn COMPLETED)
                string sqlRevenue = @"SELECT ISNULL(SUM(total_amount), 0) 
                                      FROM orders 
                                      WHERE status = 'COMPLETED' 
                                      AND created_at >= DATEADD(day, -30, GETDATE())";
                using (SqlCommand cmd = new SqlCommand(sqlRevenue, conn))
                {
                    decimal revenue = Convert.ToDecimal(cmd.ExecuteScalar());
                    litRevenue.Text = revenue.ToString("N0") + " đ";
                }

                // 2. KPI: TỔNG SỐ ĐƠN (30 ngày qua)
                string sqlCount = @"SELECT COUNT(*) 
                                    FROM orders 
                                    WHERE created_at >= DATEADD(day, -30, GETDATE())";
                using (SqlCommand cmd = new SqlCommand(sqlCount, conn))
                {
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    litOrders.Text = count.ToString("N0");
                }

                // 3. KPI: MÓN BÁN CHẠY NHẤT
                string sqlTopItem = @"SELECT TOP 1 d.dish_name
                                      FROM order_items oi
                                      JOIN dishes d ON oi.dish_id = d.dish_id
                                      GROUP BY d.dish_name
                                      ORDER BY SUM(oi.quantity) DESC";
                using (SqlCommand cmd = new SqlCommand(sqlTopItem, conn))
                {
                    object result = cmd.ExecuteScalar();
                    litTopDish.Text = result != null ? result.ToString() : "(Chưa có)";
                }

                // 4. DANH SÁCH TOP 5 MÓN ĂN (Cho Table)
                string sqlTopList = @"SELECT TOP 5 d.dish_name as DishName, 
                                             SUM(oi.quantity) as Quantity, 
                                             SUM(oi.quantity * oi.unit_price) as Revenue
                                      FROM order_items oi
                                      JOIN dishes d ON oi.dish_id = d.dish_id
                                      JOIN orders o ON oi.order_id = o.order_id
                                      WHERE o.status = 'COMPLETED'
                                      GROUP BY d.dish_name
                                      ORDER BY Quantity DESC";

                DataTable dtTop = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(sqlTopList, conn))
                {
                    da.Fill(dtTop);
                }

                if (dtTop.Rows.Count > 0)
                {
                    rptTopDishes.DataSource = dtTop;
                    rptTopDishes.DataBind();
                }
                else
                {
                    phNoData.Visible = true;
                }

                // 5. DỮ LIỆU BIỂU ĐỒ (7 ngày gần nhất)
                // Query này sẽ trả về ngày và doanh thu của ngày đó
                string sqlChart = @"SELECT FORMAT(created_at, 'dd/MM') as OrderDate, 
                                           SUM(total_amount) as Total
                                    FROM orders
                                    WHERE status = 'COMPLETED' 
                                    AND created_at >= DATEADD(day, -6, GETDATE())
                                    GROUP BY FORMAT(created_at, 'dd/MM'), CAST(created_at as DATE)
                                    ORDER BY CAST(created_at as DATE) ASC";

                List<string> labels = new List<string>();
                List<decimal> data = new List<decimal>();

                using (SqlCommand cmd = new SqlCommand(sqlChart, conn))
                {
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            labels.Add(r["OrderDate"].ToString());
                            data.Add(Convert.ToDecimal(r["Total"]));
                        }
                    }
                }

                // Chuyển đổi dữ liệu C# sang JSON để JavaScript dùng
                var chartDataObj = new
                {
                    labels = labels,
                    data = data
                };

                JavaScriptSerializer serializer = new JavaScriptSerializer();
                string jsonChartData = serializer.Serialize(chartDataObj);

                // Inject biến JSON vào trang để Script bên dưới dùng
                string script = $"window.chartData = {jsonChartData};";
                ClientScript.RegisterStartupScript(this.GetType(), "ChartData", script, true);
            }
        }
    }
}