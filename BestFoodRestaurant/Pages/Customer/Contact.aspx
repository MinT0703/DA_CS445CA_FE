<%@ Page Title="Liên hệ" Language="C#" MasterPageFile="~/MasterPages/Customer.Master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="BestFoodRestaurant.Pages.Customer.Contact" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Liên hệ - BestFood
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Styles" runat="server">
    <style>
        /* ===== Hero ===== */
        .hero-contact {
            padding: 80px 0;
            color: #fff;
            text-align: center;
            background: linear-gradient( rgba(0,0,0,.55), rgba(0,0,0,.55) ),
                        url("https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80") center/cover no-repeat;
        }
        .hero-contact h1 { margin-bottom: 10px; font-size: 36px; }

        /* ===== Layout ===== */
        .wrap-contact { padding-top: 32px; padding-bottom: 48px; }

        .contact-wrapper {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            max-width: 1200px;
            margin: 0 auto;
            align-items: stretch;
            padding: 0 20px;
        }
        @media (max-width: 960px) { .contact-wrapper { grid-template-columns: 1fr; } }

        .card-box {
            background: #fff;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 4px 14px rgba(0,0,0,.08);
            display: flex;
            flex-direction: column;
        }

        /* Form Styles */
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        @media (max-width: 600px) { .form-grid { grid-template-columns: 1fr; } }

        .form-group { margin-bottom: 14px; }
        .form-label { display: block; margin-bottom: 6px; font-weight: 600; font-size: 14px; }
        .form-control { width: 100%; padding: 12px 14px; border: 1px solid #e5e7eb; border-radius: 10px; outline: none; }
        .form-control:focus { border-color: #e74c3c; box-shadow: 0 0 0 3px rgba(231,76,60,.15); }

        .btn-send {
            padding: 12px 24px; border-radius: 10px; background: #e74c3c; color: #fff;
            border: none; cursor: pointer; font-weight: 600; margin-top: 10px;
            transition: all 0.2s;
        }
        .btn-send:hover { background: #c0392b; transform: translateY(-2px); }

        /* Info Styles */
        .info-row { display: flex; gap: 12px; margin-bottom: 16px; align-items: start; }
        .info-row i { color: #e74c3c; margin-top: 4px; }
        
        .faq-item { margin-bottom: 12px; }
        .faq-q { font-weight: 600; font-size: 14px; margin-bottom: 2px; }
        .faq-a { color: #666; font-size: 13px; }

        /* Map */
        .map-frame { width: 100%; height: 350px; border: 0; border-radius: 12px; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <section class="hero-contact">
        <div class="container">
            <h1>Liên hệ BestFood</h1>
            <p>Chúng tôi phản hồi trong vòng 24h (trong giờ làm việc)</p>
        </div>
    </section>

    <div class="wrap-contact">
        <div class="contact-wrapper">
            <div class="card-box">
                <h3 style="margin-top:0; margin-bottom:20px;">Gửi thông tin cho chúng tôi</h3>
                
                <asp:Panel ID="pnlSuccess" runat="server" Visible="false" style="background:#dcfce7; color:#166534; padding:12px; border-radius:8px; margin-bottom:15px;">
                    <i class="fas fa-check-circle"></i> Tin nhắn của bạn đã được gửi thành công!
                </asp:Panel>

                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Họ và tên</label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Nguyễn Văn A"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ErrorMessage="Nhập họ tên" Display="Dynamic" ForeColor="Red" Font-Size="12px" ValidationGroup="Contact"></asp:RequiredFieldValidator>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Số điện thoại</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="0912345678"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="Nhập SĐT" Display="Dynamic" ForeColor="Red" Font-Size="12px" ValidationGroup="Contact"></asp:RequiredFieldValidator>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="you@example.com"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Nhập Email" Display="Dynamic" ForeColor="Red" Font-Size="12px" ValidationGroup="Contact"></asp:RequiredFieldValidator>
                </div>

                <div class="form-group">
                    <label class="form-label">Chủ đề</label>
                    <asp:DropDownList ID="ddlSubject" runat="server" CssClass="form-control">
                        <asp:ListItem Value="">-- Chọn chủ đề --</asp:ListItem>
                        <asp:ListItem>Đặt bàn & đặt tiệc</asp:ListItem>
                        <asp:ListItem>Góp ý dịch vụ</asp:ListItem>
                        <asp:ListItem>Hợp tác/nhà cung cấp</asp:ListItem>
                        <asp:ListItem>Khác</asp:ListItem>
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="rfvSubject" runat="server" ControlToValidate="ddlSubject" ErrorMessage="Chọn chủ đề" Display="Dynamic" ForeColor="Red" Font-Size="12px" ValidationGroup="Contact"></asp:RequiredFieldValidator>
                </div>

                <div class="form-group">
                    <label class="form-label">Nội dung</label>
                    <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control" placeholder="Mô tả yêu cầu của bạn..."></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvMsg" runat="server" ControlToValidate="txtMessage" ErrorMessage="Nhập nội dung" Display="Dynamic" ForeColor="Red" Font-Size="12px" ValidationGroup="Contact"></asp:RequiredFieldValidator>
                </div>

                <asp:Button ID="btnSend" runat="server" Text="Gửi yêu cầu" CssClass="btn-send" OnClick="btnSend_Click" ValidationGroup="Contact" />
            </div>

            <div class="card-box">
                <h3 style="margin-top:0; margin-bottom:20px;">Thông tin liên hệ</h3>
                
                <div class="info-row">
                    <i class="fas fa-map-marker-alt"></i>
                    <div><b>Địa chỉ:</b><br>123 Đường Food, Quận 1, TP.HCM</div>
                </div>
                <div class="info-row">
                    <i class="fas fa-phone"></i>
                    <div><b>Hotline:</b><br>(028) 1234 5678 – 0909 000 111</div>
                </div>
                <div class="info-row">
                    <i class="fas fa-envelope"></i>
                    <div><b>Email:</b><br>info@bestfood.com</div>
                </div>
                <div class="info-row">
                    <i class="fas fa-clock"></i>
                    <div><b>Giờ mở cửa:</b><br>Thứ 2 – CN: 10:00 – 22:00</div>
                </div>

                <hr style="margin: 20px 0; border: 0; border-top: 1px solid #eee;">

                <h4 style="margin-top:0; margin-bottom:15px;">Câu hỏi thường gặp (FAQ)</h4>
                <div class="faq-item">
                    <div class="faq-q">• Thời gian giao hàng?</div>
                    <div class="faq-a">Trung bình 30 phút trong bán kính 5km.</div>
                </div>
                <div class="faq-item">
                    <div class="faq-q">• Đặt tiệc tối thiểu?</div>
                    <div class="faq-a">Từ 20 khách, vui lòng liên hệ trước 3–5 ngày.</div>
                </div>
                <div class="faq-item">
                    <div class="faq-q">• Chính sách hoàn tiền?</div>
                    <div class="faq-a">Miễn phí hủy trước 24h đối với đơn đặt bàn tiêu chuẩn.</div>
                </div>
            </div>

            <div class="card-box" style="padding:0; overflow:hidden;">
                <iframe class="map-frame" src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3919.4946681007846!2d106.6997639148008!3d10.773374292323565!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x31752f40a3b49e59%3A0xa1bd14e483a602db!2sBen%20Thanh%20Market!5e0!3m2!1sen!2s!4v1626078726345!5m2!1sen!2s" allowfullscreen="" loading="lazy"></iframe>
            </div>

            <div class="card-box">
                <h3 style="margin-top:0">Hệ thống cửa hàng</h3>
                <ul style="list-style:none; padding:0; line-height:2;">
                    <li><i class="fas fa-store" style="color:#e74c3c; margin-right:8px;"></i> Cơ sở 1 – Quận 1 (Flagship)</li>
                    <li><i class="fas fa-store" style="color:#e74c3c; margin-right:8px;"></i> Cơ sở 2 – Quận 7 (Gia đình)</li>
                    <li><i class="fas fa-store" style="color:#e74c3c; margin-right:8px;"></i> Cloud Kitchen – Bình Thạnh</li>
                </ul>

                <h4 style="margin-top:15px; margin-bottom:5px">Giờ cao điểm</h4>
                <p style="color:#666; font-size:14px; margin-bottom:15px">11:30 – 13:30 & 18:00 – 20:00. Khuyên bạn đặt bàn trước để giữ chỗ.</p>

                <asp:HyperLink ID="lnkBooking" runat="server" NavigateUrl="Booking.aspx" CssClass="btn-send" style="display:inline-block; text-align:center; text-decoration:none;">Đặt bàn ngay</asp:HyperLink>
            </div>
        </div>
    </div>
</asp:Content>