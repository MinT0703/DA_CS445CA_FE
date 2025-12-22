using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace BestFoodRestaurant.Pages.Customer
{
    // Class phụ để hứng dữ liệu lịch sử từ JSON
    public class ClientChatMessage
    {
        public string from { get; set; }
        public string text { get; set; }
    }

    public partial class ChatBot : System.Web.UI.Page
    {
        private static readonly string GEMINI_API_KEY = "AIzaSyDnVz00JkJcXfq59BW_AESGadTFX-0G2uI"; 
        private static readonly string GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + GEMINI_API_KEY;

        protected void Page_Load(object sender, EventArgs e) { }

        [WebMethod(EnableSession = true)]
        public static string GetBotResponse(string userMessage, List<ClientChatMessage> history)
        {
            try
            {
                // 1. Chuẩn bị Context (Giữ nguyên như cũ)
                string menuContext = GetMenuFromDatabase();
                string userHistoryContext = "Khách hàng chưa đăng nhập.";
                string reservationContext = "(Không có thông tin)";
                string userName = "Bạn";
                int userId = 0;

                if (HttpContext.Current != null && HttpContext.Current.Session != null && HttpContext.Current.Session["CustomerID"] != null)
                {
                    userId = (int)HttpContext.Current.Session["CustomerID"];
                    userName = HttpContext.Current.Session["CustomerName"]?.ToString() ?? "Khách hàng";
                    userHistoryContext = GetUserDiningHistory(userId);
                    reservationContext = GetUserUpcomingReservations(userId);
                }

                StringBuilder historyBuilder = new StringBuilder();
                if (history != null && history.Count > 0)
                {
                    foreach (var msg in history)
                    {
                        if (!string.IsNullOrEmpty(msg.text) && !msg.text.Contains("fa-ellipsis-h"))
                        {
                            string role = (msg.from == "user") ? "Khách" : "Bot";
                            historyBuilder.AppendLine($"{role}: {msg.text}");
                        }
                    }
                }
                string conversationHistory = historyBuilder.ToString();

                // 2. Gọi AI
                string aiResponse = Task.Run(async () => await GetResponseAsync(userMessage, userName, userHistoryContext, menuContext, reservationContext, conversationHistory, DateTime.Now)).Result;

                // 3. XỬ LÝ LỆNH THÔNG MINH (Sửa lỗi bot trả lời thừa chữ)
                // Thay vì StartsWith, ta dùng Contains để tìm lệnh dù nó nằm ở đâu

                // --- TRƯỜNG HỢP ĐẶT BÀN ---
                if (aiResponse.Contains("CMD:BOOK"))
                {
                    if (userId == 0) return "Bạn cần đăng nhập để đặt bàn nhé! 🔒";
                    try
                    {
                        // Lọc lấy đúng phần lệnh CMD:BOOK...
                        string command = ExtractCommand(aiResponse, "CMD:BOOK");
                        string[] parts = command.Split('|');
                        // CMD:BOOK|2025-12-22|21:00|3
                        return BookTable(userId, parts[1], parts[2], int.Parse(parts[3]), userName);
                    }
                    catch { return "⚠️ Thông tin chưa rõ. Bạn chốt lại giúp mình: Ngày, giờ và số người?"; }
                }

                // --- TRƯỜNG HỢP HỦY BÀN ---
                if (aiResponse.Contains("CMD:CANCEL"))
                {
                    if (userId == 0) return "Bạn cần đăng nhập để hủy bàn! 🔒";
                    try
                    {
                        string command = ExtractCommand(aiResponse, "CMD:CANCEL");
                        string[] parts = command.Split('|');
                        return CancelReservation(userId, int.Parse(parts[1]));
                    }
                    catch { return "⚠️ Không tìm thấy đơn cần hủy."; }
                }

                return aiResponse;
            }
            catch (Exception ex)
            {
                return "Lỗi: " + ex.Message;
            }
        }

        // --- HÀM PHỤ TRỢ: Tách lệnh ra khỏi câu nói ---
        // Ví dụ input: "Oke anh. CMD:BOOK|...|... Chúc anh ngon miệng"
        // Output: "CMD:BOOK|...|..."
        private static string ExtractCommand(string rawResponse, string cmdType)
        {
            int startIndex = rawResponse.IndexOf(cmdType);
            if (startIndex == -1) return "";

            // Lấy chuỗi từ vị trí CMD trở đi
            string substring = rawResponse.Substring(startIndex);

            // Lệnh thường kết thúc ở cuối dòng hoặc cuối chuỗi. 
            // Ta lấy đến hết dòng (nếu có xuống dòng) hoặc hết chuỗi.
            int endIndex = substring.IndexOf('\n');
            if (endIndex == -1) return substring.Trim();

            return substring.Substring(0, endIndex).Trim();
        }

        private static async Task<string> GetResponseAsync(string userMessage, string userName, string historyContext, string menuContext, string reservationContext, string conversationHistory, DateTime now)
        {
            // PROMPT THÔNG MINH (Kèm ngữ cảnh lịch sử)
            string systemPrompt = $@"
                Bạn là trợ lý AI nhà hàng BestFood.
                Tên khách: {userName}. Hiện tại: {now:yyyy-MM-dd HH:mm}.

                [THÔNG TIN QUÁN & KHÁCH]:
                - Menu: {menuContext}
                - Gu ăn uống khách: {historyContext}
                - Lịch đặt bàn khách: {reservationContext}

                [HỘI THOẠI GẦN ĐÂY] (Quan trọng để hiểu ngữ cảnh):
                {conversationHistory}
                Khách (mới nhất): ""{userMessage}""

                NHIỆM VỤ:
                1. Trả lời tiếp nối hội thoại trên một cách tự nhiên.
                2. NẾU ĐẶT BÀN: Kiểm tra thông tin trong CẢ hội thoại cũ.
                   - Ví dụ: Khách nói 'Đặt 21h' ở câu trước, câu này nói '3 người' -> Đủ thông tin.
                   - Trả về: CMD:BOOK|yyyy-MM-dd|HH:mm|Số_người
                3. NẾU HỦY BÀN: Trả về CMD:CANCEL|ReservationID

                Chỉ trả về CMD nếu chắc chắn.
            ";

            using (HttpClient client = new HttpClient())
            {
                var payload = new { contents = new[] { new { parts = new[] { new { text = systemPrompt } } } } };
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                string jsonContent = serializer.Serialize(payload);
                StringContent httpContent = new StringContent(jsonContent, Encoding.UTF8, "application/json");

                HttpResponseMessage response = await client.PostAsync(GEMINI_URL, httpContent);
                string resultJson = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    dynamic resultObj = serializer.Deserialize<dynamic>(resultJson);
                    try { return resultObj["candidates"][0]["content"]["parts"][0]["text"].Trim(); }
                    catch { return "Bot đang suy nghĩ..."; }
                }
                return "Lỗi kết nối AI.";
            }
        }

        // --- CÁC HÀM XỬ LÝ DATABASE (BOOK/CANCEL/GET...) ---
        // Giữ nguyên logic cũ, chỉ copy lại để code chạy được

        private static string BookTable(int userId, string date, string time, int guests, string userName)
        {
            string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    DateTime reserveTime = DateTime.Parse($"{date} {time}");
                    if (reserveTime < DateTime.Now) return "⚠️ Không thể đặt thời gian quá khứ.";
                    string sql = "INSERT INTO reservations (customer_id, reservation_datetime, guest_count, note, status, created_via, created_at) VALUES (@uid, @time, @guests, N'Chatbot', 'PENDING', 'CHATBOT', GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.Parameters.AddWithValue("@time", reserveTime);
                        cmd.Parameters.AddWithValue("@guests", guests);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        return $"✅ Đã đặt bàn cho {guests} người lúc {time} ngày {date}.";
                    }
                }
            }
            catch { return "Lỗi lưu đơn."; }
        }

        private static string CancelReservation(int userId, int reservationId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sqlCheck = "SELECT reservation_datetime, status FROM reservations WHERE reservation_id = @rid AND customer_id = @uid";
                using (SqlCommand cmd = new SqlCommand(sqlCheck, conn))
                {
                    cmd.Parameters.AddWithValue("@rid", reservationId);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) return "❌ Không tìm thấy đơn.";
                        if (r["status"].ToString() == "CANCELLED") return "Đơn đã hủy rồi.";
                        if ((Convert.ToDateTime(r["reservation_datetime"]) - DateTime.Now).TotalHours < 12) return "⚠️ Chỉ được hủy trước 12 tiếng.";
                    }
                }
                string sqlUpdate = "UPDATE reservations SET status = 'CANCELLED' WHERE reservation_id = @rid";
                using (SqlCommand cmd = new SqlCommand(sqlUpdate, conn))
                {
                    cmd.Parameters.AddWithValue("@rid", reservationId);
                    cmd.ExecuteNonQuery();
                    return "✅ Đã hủy bàn thành công.";
                }
            }
        }

        private static string GetUserUpcomingReservations(int userId)
        {
            StringBuilder sb = new StringBuilder();
            string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = "SELECT reservation_id, reservation_datetime, guest_count FROM reservations WHERE customer_id = @uid AND (status = 'PENDING' OR status = 'CONFIRMED') AND reservation_datetime > GETDATE() ORDER BY reservation_datetime ASC";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        conn.Open();
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (!r.HasRows) return "(Không có lịch)";
                            while (r.Read())
                            {
                                DateTime dt = Convert.ToDateTime(r["reservation_datetime"]);
                                sb.AppendLine($"- Mã {r["reservation_id"]}: {dt:dd/MM HH:mm} ({r["guest_count"]} người)");
                            }
                        }
                    }
                }
            }
            catch { return ""; }
            return sb.ToString();
        }

        private static string GetUserDiningHistory(int userId)
        {
            // Logic lấy lịch sử món ăn (Code cũ)
            StringBuilder sb = new StringBuilder();
            string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = @"SELECT TOP 3 d.dish_name, SUM(oi.quantity) as total_qty FROM orders o JOIN order_items oi ON o.order_id = oi.order_id JOIN dishes d ON oi.dish_id = d.dish_id WHERE o.customer_id = @uid GROUP BY d.dish_name ORDER BY total_qty DESC";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        conn.Open();
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read()) sb.AppendLine($"- {r["dish_name"]}");
                        }
                    }
                }
            }
            catch { return ""; }
            return sb.ToString();
        }

        private static string GetMenuFromDatabase()
        {
            StringBuilder sb = new StringBuilder();
            string connStr = ConfigurationManager.ConnectionStrings["SmartRestaurantConnectionString"]?.ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = "SELECT dish_name, price FROM dishes WHERE is_available = 1";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        conn.Open();
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read()) sb.AppendLine($"- {r["dish_name"]}: {Convert.ToDecimal(r["price"]):N0}đ");
                        }
                    }
                }
            }
            catch { return ""; }
            return sb.ToString();
        }
    }
}