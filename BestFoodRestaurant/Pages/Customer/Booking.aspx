<%@ Page Title="Đặt bàn online" Language="C#" MasterPageFile="~/MasterPages/Customer.Master" AutoEventWireup="true" CodeBehind="Booking.aspx.cs" Inherits="BestFoodRestaurant.Pages.Customer.Booking" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Đặt bàn - BestFood
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Styles" runat="server">
    <style>
        .booking-wrap { max-width:1200px; margin: 30px auto; padding: 0 20px; }
        .booking-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 30px; }
        @media(max-width:900px){ .booking-grid { grid-template-columns: 1fr; } }

        .card-form { background:#fff; border-radius:16px; padding:28px; box-shadow: 0 4px 15px rgba(0,0,0,0.08); }
        .card-form h3 { margin-top:0; color:#e74c3c; margin-bottom: 20px; border-bottom: 1px solid #eee; padding-bottom: 10px; }

        .form-group { margin-bottom: 16px; }
        .form-label { display: block; margin-bottom: 8px; font-weight: 600; font-size: 14px; }
        .form-control { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 15px; }
        .form-control:focus { border-color: #e74c3c; outline: none; box-shadow: 0 0 0 3px rgba(231,76,60,.1); }

        .row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }

        .btn-book {
            width: 100%; padding: 14px; background: #e74c3c; color: #fff;
            border: none; border-radius: 10px; font-weight: 700; font-size: 16px;
            cursor: pointer; transition: all 0.3s; margin-top: 10px;
        }
        .btn-book:hover { background: #c0392b; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(231,76,60,.3); }

        /* History List */
        .history-list { max-height: 500px; overflow-y: auto; }
        .booking-item {
            background: #f9f9f9; border: 1px solid #eee; border-radius: 10px; padding: 15px; margin-bottom: 12px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .bk-info div { margin-bottom: 4px; }
        .bk-status { font-size: 12px; font-weight: 700; padding: 4px 10px; border-radius: 20px; }
        .st-PENDING { background: #fff3cd; color: #856404; }
        .st-CONFIRMED { background: #d1e7dd; color: #0f5132; }
        .st-CANCELLED { background: #f8d7da; color: #721c24; }

        .alert-box { padding: 15px; border-radius: 8px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="booking-wrap">
        <div class="booking-grid">
            <section class="card-form">
                <h3><i class="fas fa-calendar-alt"></i> Thông tin đặt bàn</h3>
                
                <asp:Panel ID="pnlMsg" runat="server" Visible="false" CssClass="alert-box">
                    <asp:Label ID="lblMsg" runat="server"></asp:Label>
                </asp:Panel>

                <div class="form-group">
                    <label class="form-label">Số điện thoại <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="0912345678"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="Vui lòng nhập SĐT" Display="Dynamic" ForeColor="Red" ValidationGroup="Book"></asp:RequiredFieldValidator>
                </div>

                <div class="row-2">
                    <div class="form-group">
                        <label class="form-label">Ngày đặt <span style="color:red">*</span></label>
                        <asp:TextBox ID="txtDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvDate" runat="server" ControlToValidate="txtDate" ErrorMessage="Chọn ngày" Display="Dynamic" ForeColor="Red" ValidationGroup="Book"></asp:RequiredFieldValidator>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Giờ đến <span style="color:red">*</span></label>
                        <asp:TextBox ID="txtTime" runat="server" TextMode="Time" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvTime" runat="server" ControlToValidate="txtTime" ErrorMessage="Chọn giờ" Display="Dynamic" ForeColor="Red" ValidationGroup="Book"></asp:RequiredFieldValidator>
                    </div>
                </div>

                <div class="row-2">
                    <div class="form-group">
                        <label class="form-label">Chọn bàn (Tùy chọn)</label>
                        <asp:DropDownList ID="ddlTable" runat="server" CssClass="form-control" AppendDataBoundItems="true">
                            <asp:ListItem Value="">-- Để quán tự sắp xếp --</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Số người <span style="color:red">*</span></label>
                        <asp:TextBox ID="txtGuests" runat="server" TextMode="Number" CssClass="form-control" min="1" max="50" Text="2"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvGuests" runat="server" ControlToValidate="txtGuests" ErrorMessage="Nhập số khách" Display="Dynamic" ForeColor="Red" ValidationGroup="Book"></asp:RequiredFieldValidator>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Ghi chú (Yêu cầu đặc biệt)</label>
                    <asp:TextBox ID="txtNote" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" placeholder="Ví dụ: Có trẻ em, cần ghế cao, tổ chức sinh nhật..."></asp:TextBox>
                </div>

                <asp:Button ID="btnBook" runat="server" Text="Xác nhận đặt bàn" CssClass="btn-book" OnClick="btnBook_Click" ValidationGroup="Book" />
            </section>

            <aside class="card-form">
                <h3><i class="fas fa-history"></i> Lịch sử đặt bàn</h3>
                <div class="history-list">
                    <asp:Repeater ID="rptHistory" runat="server">
                        <ItemTemplate>
                            <div class="booking-item">
                                <div class="bk-info">
                                    <div style="font-weight:700; font-size:15px">
                                        <%# Eval("reservation_datetime", "{0:dd/MM/yyyy HH:mm}") %>
                                    </div>
                                    <div style="font-size:13px; color:#555">
                                        <%# Eval("guest_count") %> khách 
                                        <span style="margin:0 5px">•</span> 
                                        <%# Eval("table_code") != DBNull.Value ? "Bàn " + Eval("table_code") : "Bàn tự chọn" %>
                                    </div>
                                    <div style="font-size:12px; color:#999; font-style:italic">
                                        <%# Eval("note") %>
                                    </div>
                                </div>
                                <div>
                                    <span class="bk-status st-<%# Eval("status") %>"><%# Eval("status") %></span>
                                </div>
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:Label ID="lblEmpty" runat="server" Text="Chưa có lịch sử đặt bàn." Visible='<%# rptHistory.Items.Count == 0 %>' style="color:#777; font-style:italic; display:block; text-align:center; padding:20px;"></asp:Label>
                        </FooterTemplate>
                    </asp:Repeater>
                    
                    <asp:Panel ID="pnlLoginHint" runat="server" Visible="false" style="text-align:center; padding:20px; color:#666;">
                        <i class="fas fa-lock" style="font-size:24px; margin-bottom:10px; display:block; color:#ccc;"></i>
                        Vui lòng <a href="Login.aspx" style="color:#e74c3c; font-weight:700">đăng nhập</a> để xem lịch sử đặt bàn của bạn.
                    </asp:Panel>
                </div>
            </aside>
        </div>
    </div>
</asp:Content>