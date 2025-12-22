<%@ Page Title="Giới thiệu" Language="C#" MasterPageFile="~/MasterPages/Customer.Master" AutoEventWireup="true" CodeBehind="AboutUs.aspx.cs" Inherits="BestFoodRestaurant.Pages.Customer.AboutUs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Giới thiệu - BestFood
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Styles" runat="server">
    <style>
        /* ===== Hero About ===== */
        .hero-about {
            padding: 90px 0;
            color: #fff;
            text-align: center;
            background: linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
                        url("https://images.unsplash.com/photo-1526318472351-c75fcf070305?q=80&w=1400&auto=format&fit=crop") center/cover no-repeat;
        }
        .hero-about h1 {
            font-size: 40px;
            font-weight: 800;
            margin-bottom: 10px;
        }
        .hero-about p {
            font-size: 18px;
            opacity: .9;
        }
        .hero-about .pill {
            background: #f43f5e;
            color: #fff;
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: .5px;
        }

        /* KPIs */
        .kpis {
            display: grid;
            grid-template-columns: repeat(4,minmax(0,1fr));
            gap: 16px;
            margin-top: 24px;
        }
        .kpis .card {
            background: rgba(255,255,255,.1);
            padding: 16px;
            border-radius: 12px;
            backdrop-filter: blur(4px);
            color: #fff;
            text-align: center;
        }
        .kpis .big {
            font-weight: 800;
            font-size: 28px;
            color: #fff;
        }
        @media(max-width: 768px) {
            .kpis { grid-template-columns: 1fr 1fr; }
        }

        /* ===== Layout Sections ===== */
        .wrap-about {
            max-width: 1200px;
            margin: 32px auto;
            padding: 0 20px;
            display: flex;
            flex-direction: column;
            gap: 32px;
        }

        .grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }
        @media(max-width: 900px) {
            .grid-2 { grid-template-columns: 1fr; }
        }

        .card-box {
            background: #fff;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.06);
        }
        .card-box h3 { margin-top: 0; margin-bottom: 12px; color: var(--dark-color); }
        .card-box p { color: #555; line-height: 1.6; margin-bottom: 12px; }

        .list-check { list-style: none; padding: 0; }
        .list-check li { margin-bottom: 8px; display: flex; gap: 10px; align-items: center; }
        .list-check li i { color: #27ae60; }

        .timeline .row { margin-bottom: 8px; border-left: 3px solid #eee; padding-left: 12px; margin-left: 4px; }
        .timeline b { color: var(--primary-color); }

        .pill-red {
            background: #fee2e2; color: #991b1b; 
            padding: 6px 12px; border-radius: 20px; font-size: 13px; font-weight: 600;
            display: inline-flex; align-items: center; gap: 6px;
        }

        /* Team */
        .team-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 16px;
            text-align: center;
        }
        .team-member img {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            object-fit: cover;
            margin-bottom: 10px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        .team-member h4 { margin: 0; font-size: 16px; color: #333; }
        .team-member .role { font-size: 13px; color: #777; }

        /* CTA Button */
        .btn-cta {
            display: inline-block;
            padding: 12px 28px;
            margin-top: 12px;
            border-radius: 8px;
            background: #e74c3c;
            color: #fff;
            text-decoration: none;
            font-weight: 600;
            transition: 0.3s;
        }
        .btn-cta:hover { background: #c0392b; transform: translateY(-2px); }
        
        /* Utility pills */
        .pill-tag {
            display: inline-flex; align-items: center; gap: 6px;
            background: #f3f4f6; color: #4b5563;
            padding: 6px 12px; border-radius: 20px; font-size: 13px; font-weight: 500;
            margin-right: 8px; margin-top: 8px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <section class="hero-about">
        <div class="container">
            <span class="pill">#Since 2010</span>
            <h1>Chúng tôi kể chuyện bằng hương vị</h1>
            <p>Nguyên liệu chuẩn – quy trình chuẩn – trải nghiệm chuẩn</p>
            <div class="kpis">
                <div class="card"><div class="big">150K+</div><div>khách hàng/năm</div></div>
                <div class="card"><div class="big">120+</div><div>món trong menu</div></div>
                <div class="card"><div class="big">30'</div><div>giao hàng trung bình</div></div>
                <div class="card"><div class="big">4.8/5</div><div>điểm hài lòng</div></div>
            </div>
        </div>
    </section>

    <div class="wrap-about">
        <section class="grid-2">
            <div class="card-box">
                <h3>Sứ mệnh</h3>
                <p>BestFood mang đến bữa ăn chất lượng nhà hàng với mức giá hợp lý. Chúng tôi ưu tiên nguyên liệu địa phương, tươi theo mùa và quy trình bếp mở minh bạch – để mỗi bữa ăn là một trải nghiệm đáng nhớ.</p>
                <ul class="list-check">
                    <li><i class="fas fa-check"></i> Ngon – lành – chuẩn an toàn</li>
                    <li><i class="fas fa-check"></i> Tôn trọng sự đa dạng ẩm thực (eat clean, vegan, gluten-free…)</li>
                    <li><i class="fas fa-check"></i> Trải nghiệm dịch vụ 5⭐ từ online đến tại quán</li>
                </ul>
            </div>
            <div class="card-box">
                <h3>Tại sao chọn chúng tôi?</h3>
                <div class="timeline">
                    <div class="row"><b>2010</b> – Thành lập BestFood tại TP.HCM</div>
                    <div class="row"><b>2015</b> – Ra mắt app đặt món và giao hàng</div>
                    <div class="row"><b>2019</b> – Đạt mốc 1 triệu đơn online</div>
                    <div class="row"><b>2024</b> – Nâng cấp bếp cloud & menu mùa vụ</div>
                </div>
                <div style="margin-top:12px"><span class="pill-red"><i class="fas fa-leaf"></i> Cam kết bền vững</span></div>
            </div>
        </section>

        <section class="grid-2">
            <div class="card-box" style="padding: 0; overflow: hidden;">
                <img src="https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=1200&auto=format&fit=crop" alt="Bếp BestFood" style="width:100%; height:100%; object-fit:cover; display:block;">
            </div>
            <div class="card-box">
                <h3>Nhà bếp mở – quy trình chuẩn</h3>
                <p>Chúng tôi vận hành theo chuẩn HACCP, kiểm soát chặt chẽ nhiệt độ – thời gian – vệ sinh tại từng công đoạn. Từ sơ chế đến đóng gói giao hàng đều có nhật ký theo lô.</p>
                <div class="pill-tag"><i class="fas fa-temperature-low"></i> Cold-chain</div>
                <div class="pill-tag"><i class="fas fa-shipping-fast"></i> 30' Delivery</div>
                <div class="pill-tag"><i class="fas fa-seedling"></i> Farm-to-Table</div>
            </div>
        </section>

        <section class="card-box">
            <h3 style="text-align:center">Đội ngũ</h3>
            <p style="text-align:center; color:#777; margin-top:-10px">Những người giữ lửa tại BestFood</p>
            <div class="team-grid">
                <div class="team-member">
                    <img src="https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=800&auto=format&fit=crop" alt="Chef 1"/>
                    <h4>Trần Minh Khôi</h4>
                    <div class="role">Bếp trưởng</div>
                </div>
                <div class="team-member">
                    <img src="https://images.unsplash.com/photo-1544717305-2782549b5136?q=80&w=800&auto=format&fit=crop" alt="Chef 2"/>
                    <h4>Nguyễn Diệu Anh</h4>
                    <div class="role">R&D Menu</div>
                </div>
                <div class="team-member">
                    <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=800&auto=format&fit=crop" alt="Chef 3"/>
                    <h4>Hồ Bảo Lâm</h4>
                    <div class="role">Ops Delivery</div>
                </div>
                <div class="team-member">
                    <img src="https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=800&auto=format&fit=crop" alt="Chef 4"/>
                    <h4>Vũ Quỳnh Mai</h4>
                    <div class="role">QC & Training</div>
                </div>
            </div>
        </section>

        <section class="card-box" style="text-align:center">
            <h3>Tham quan bếp hoặc hợp tác cùng BestFood</h3>
            <p>Chúng tôi luôn chào đón đối tác nguyên liệu, logistic & sự kiện</p>
            <asp:HyperLink ID="lnkContactCTA" runat="server" NavigateUrl="Contact.aspx" CssClass="btn-cta">Liên hệ ngay</asp:HyperLink>
        </section>
    </div>
</asp:Content>