<%@ Page Title="Trang chủ" Language="C#" MasterPageFile="~/MasterPages/Customer.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="BestFoodRestaurant.Pages.Customer.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Trang chủ - BestFood
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Styles" runat="server">
    <style>
        .hero {
            text-align: center;
            padding: 100px 20px;
            background: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)),
            url("https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80");
            background-size: cover;
            background-position: center;
            color: white;
            border-radius: 0 0 20px 20px; /* Bo góc nhẹ dưới hero cho mềm mại */
        }
        
        /* Thêm chút hiệu ứng hover cho các card */
        .menu-card, .catering-card, .delivery-text, .testimonial {
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .menu-card:hover, .catering-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }

        /* Blog Card Styles (Bổ sung CSS cho Blog vì JS render ra class này) */
        .blog-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }
        .blog-card {
            background: #fff;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
            transition: all 0.3s;
        }
        .blog-card:hover { transform: translateY(-3px); }
        .blog-image {
            height: 200px;
            background-size: cover;
            background-position: center;
        }
        .blog-content { padding: 20px; }
        .blog-content h3 { margin-top: 0; font-size: 18px; margin-bottom: 10px; }
        .blog-meta { font-size: 12px; color: #888; margin-bottom: 10px; display: flex; gap: 10px; }
        .btn-small { padding: 8px 16px; font-size: 13px; margin-top: 10px; display: inline-block; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <section class="hero">
        <div class="container">
            <h1>Món ăn ngon nhất cho khẩu vị của bạn</h1>
            <p style="font-size: 1.2rem; margin-bottom: 30px;">
                Khám phá thực đơn hấp dẫn của chúng tôi với nguyên liệu tươi ngon và đam mê nấu nướng
            </p>
            <asp:HyperLink ID="lnkHeroMenu" runat="server" NavigateUrl="~/Pages/Customer/Menu.aspx" CssClass="btn">Xem Thực Đơn</asp:HyperLink>

            <div class="menu-browse">
                <div class="menu-card">
                    <i class="fas fa-utensils"></i>
                    <h3>Khai vị</h3>
                    <p>Bắt đầu bữa ăn đúng cách</p>
                </div>
                <div class="menu-card">
                    <i class="fas fa-hamburger"></i>
                    <h3>Món chính</h3>
                    <p>No nê và hấp dẫn</p>
                </div>
                <div class="menu-card">
                    <i class="fas fa-ice-cream"></i>
                    <h3>Tráng miệng</h3>
                    <p>Kết thúc ngọt ngào</p>
                </div>
                <div class="menu-card">
                    <i class="fas fa-cocktail"></i>
                    <h3>Đồ uống</h3>
                    <p>Giải khát sảng khoái</p>
                </div>
            </div>
        </div>
    </section>

    <section class="healthy-section">
        <div class="container">
            <div class="healthy-text">
                <h2>Bữa ăn lành mạnh cho gia đình bạn</h2>
                <p>
                    Đầu bếp của chúng tôi chỉ sử dụng nguyên liệu tươi ngon nhất để tạo ra những món ăn bổ dưỡng và hấp dẫn mà cả gia đình bạn sẽ yêu thích.
                </p>
                <a href="#" class="btn">Tìm hiểu thêm</a>
            </div>

            <div class="healthy-card">
                <i class="fas fa-heart" style="color: #e74c3c; font-size: 40px; margin-bottom: 15px;"></i>
                <h3>Đặt món theo yêu cầu</h3>
                <p>
                    Hãy cho chúng tôi biết chế độ ăn uống của bạn (Vegan, Keto, Das...) và chúng tôi sẽ chuẩn bị món ăn phù hợp.
                </p>
            </div>
        </div>
    </section>

    <section class="catering-section">
        <div class="container">
            <h2 class="section-title">Dịch vụ tiệc</h2>
            <div class="catering-grid">
                <div class="catering-card">
                    <i class="fas fa-glass-cheers"></i>
                    <h3>Tiệc cưới</h3>
                    <p>Biến ngày trọng đại của bạn trở nên đáng nhớ với thực đơn sang trọng.</p>
                </div>
                <div class="catering-card">
                    <i class="fas fa-briefcase"></i>
                    <h3>Sự kiện công ty</h3>
                    <p>Tạo ấn tượng với khách hàng và đồng nghiệp bằng dịch vụ chuyên nghiệp.</p>
                </div>
                <div class="catering-card">
                    <i class="fas fa-birthday-cake"></i>
                    <h3>Tiệc riêng tư</h3>
                    <p>Từ sinh nhật đến kỷ niệm, chúng tôi đều có thể phục vụ chu đáo.</p>
                </div>
                <div class="catering-card">
                    <i class="fas fa-calendar-alt"></i>
                    <h3>Sự kiện đặc biệt</h3>
                    <p>Lễ hội, lễ tốt nghiệp và nhiều hơn nữa - chúng tôi đều lo được.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="delivery-section">
        <div class="container">
            <div class="delivery-image">
                <img src="https://kamereo.vn/blog/wp-content/uploads/2019/05/freepik_featured_delivery-930x620.jpg" alt="Giao đồ ăn" />
            </div>
            <div class="delivery-text">
                <h2>Giao hàng nhanh nhất thành phố</h2>
                <p>
                    Chúng tôi đảm bảo giao hàng trong vòng 30 phút hoặc miễn phí! Đội ngũ giao hàng tận tâm luôn giữ đồ ăn nóng hổi và tươi ngon.
                </p>

                <div class="special-offers">
                    <h3>Ưu đãi đặc biệt</h3>
                    <ul>
                        <li><i class="fas fa-check-circle" style="color:#27ae60"></i> Miễn phí giao hàng cho đơn trên 500.000đ</li>
                        <li><i class="fas fa-check-circle" style="color:#27ae60"></i> Giảm 20% cho đơn online đầu tiên</li>
                        <li><i class="fas fa-check-circle" style="color:#27ae60"></i> Tích điểm nhận thưởng mỗi đơn hàng</li>
                    </ul>
                </div>

                <asp:HyperLink ID="lnkOrderNow" runat="server" NavigateUrl="~/Pages/Customer/Menu.aspx" CssClass="btn">Đặt ngay</asp:HyperLink>
            </div>
        </div>
    </section>

    <section class="testimonials">
        <div class="container">
            <h2 class="section-title">Khách hàng nói gì</h2>
            <div class="testimonial-grid">
                <div class="testimonial">
                    <div class="testimonial-content">
                        <p>"Đồ ăn ở đây thực sự tuyệt vời! Tôi đã là khách quen hơn một năm và luôn ấn tượng với chất lượng."</p>
                        <div class="testimonial-author">
                            <img src="https://randomuser.me/api/portraits/women/32.jpg" alt="User" />
                            <div>
                                <h4>Sarah Johnson</h4>
                                <p>Khách hàng thường xuyên</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="testimonial">
                    <div class="testimonial-content">
                        <p>"Chúng tôi đã thuê BestFood cho sự kiện công ty và mọi người đều khen ngợi. Dịch vụ chuyên nghiệp!"</p>
                        <div class="testimonial-author">
                            <img src="https://randomuser.me/api/portraits/men/46.jpg" alt="User" />
                            <div>
                                <h4>Michael Chen</h4>
                                <p>Người tổ chức sự kiện</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="testimonial">
                    <div class="testimonial-content">
                        <p>"Là người có chế độ ăn kiêng, tôi rất thích cách họ phục vụ. Các món không gluten vẫn rất ngon!"</p>
                        <div class="testimonial-author">
                            <img src="https://randomuser.me/api/portraits/women/65.jpg" alt="User" />
                            <div>
                                <h4>Emily Rodriguez</h4>
                                <p>Healthy Food Lover</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="blog-section">
        <div class="container">
            <h2 class="section-title">Bài viết mới nhất</h2>
            <div class="blog-grid" id="blogGrid">
                </div>
        </div>
    </section>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        // SỬA LỖI: Đổi tên biến $ thành 'select' để tránh xung đột với jQuery
        const select = s => document.querySelector(s);
        const show = (el, on = true) => el.style.display = on ? 'block' : 'none';

        function fmtDate(d) {
            if (!d) return '';
            try { const parts = d.split(' ')[0].split('-'); return `${parts[2]}/${parts[1]}/${parts[0]}`; } catch { return d; }
        }
        function truncate(s, n = 100) { if (!s) return ''; return s.length > n ? s.slice(0, n - 1) + '…' : s; }

        // Ảnh placeholder đẹp hơn
        function blogImage(src) {
            return src && src.trim() ? src : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80';
        }

        function renderBlogs(items) {
            const grid = document.getElementById('blogGrid');
            if (!grid) return;

            if (!Array.isArray(items) || items.length === 0) {
                grid.innerHTML = `<div class="muted" style="padding:12px 0; text-align:center; grid-column: 1/-1;">Chưa có bài viết nào.</div>`;
                return;
            }

            grid.innerHTML = items.map(b => {
                const img = blogImage(b.hinh_anh);
                const title = b.title || 'Bài viết';
                const desc = truncate(b.mo_ta_ngan || b.description || '');
                const date = fmtDate(b.ngay_dang || b.created_at || '');
                const cmt = typeof b.so_binh_luan !== 'undefined' ? `<span><i class="far fa-comment"></i> ${b.so_binh_luan}</span>` : '';

                return `
                  <div class="blog-card">
                    <div class="blog-image" style="background-image:url('${img}');"></div>
                    <div class="blog-content">
                      <h3>${title}</h3>
                      <div class="blog-meta">
                        <span><i class="far fa-calendar-alt"></i> ${date}</span>
                        ${cmt}
                      </div>
                      <p>${desc}</p>
                      <a href="#" class="btn btn-small" style="background:#e74c3c; color:#fff; text-decoration:none; border-radius:5px;">Đọc thêm</a>
                    </div>
                  </div>
                `;
            }).join('');
        }

        document.addEventListener('DOMContentLoaded', () => {
            // Dữ liệu mẫu (Mock data)
            const mockBlogs = [
                {
                    title: "5 Công thức Smoothie giúp đẹp da",
                    mo_ta_ngan: "Tổng hợp những công thức sinh tố đơn giản từ rau củ quả tự nhiên giúp làn da tươi sáng...",
                    created_at: "2025-01-15",
                    hinh_anh: "https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=800&q=80"
                },
                {
                    title: "Bí quyết chọn thịt bò tươi ngon",
                    mo_ta_ngan: "Làm sao để phân biệt thịt bò tươi và thịt bò đông lạnh? Hãy cùng tìm hiểu...",
                    created_at: "2025-01-10",
                    hinh_anh: "https://images.unsplash.com/photo-1603048297172-c92544798d5e?auto=format&fit=crop&w=800&q=80"
                },
                {
                    title: "Xu hướng ẩm thực xanh 2025",
                    mo_ta_ngan: "Ăn sạch, sống xanh đang là xu hướng toàn cầu. BestFood cam kết đồng hành cùng bạn...",
                    created_at: "2025-01-05",
                    hinh_anh: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80"
                }
            ];
            renderBlogs(mockBlogs);
        });
    </script>
</asp:Content>