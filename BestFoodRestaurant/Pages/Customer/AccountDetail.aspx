<%@ Page Title="Tài khoản của tôi" Language="C#" MasterPageFile="~/MasterPages/Customer.Master" AutoEventWireup="true" CodeBehind="AccountDetail.aspx.cs" Inherits="BestFoodRestaurant.Pages.Customer.AccountDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Tài khoản - BestFood
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Styles" runat="server">
    <style>
        .account-wrap {
            max-width: 1200px;
            margin: 24px auto;
            padding: 0 20px;
        }

        .account-grid {
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 24px;
            align-items: start;
        }

        @media(max-width:900px) {
            .account-grid {
                grid-template-columns: 1fr;
            }
        }

        /* Sidebar */
        .sidebar {
            background: #fff;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .user-mini {
            display: flex;
            gap: 12px;
            align-items: center;
            padding-bottom: 15px;
            border-bottom: 1px solid #f3f4f6;
            margin-bottom: 10px;
        }

        .avatar-sm {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #e74c3c;
        }

        .nav-btn {
            display: block;
            width: 100%;
            text-align: left;
            padding: 12px 15px;
            border-radius: 8px;
            border: none;
            background: transparent;
            color: #333;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 14px;
        }

            .nav-btn:hover {
                background: #f9f9f9;
                color: #e74c3c;
            }

            .nav-btn.active {
                background: #fff5f5;
                color: #e74c3c;
                font-weight: 700;
            }

            .nav-btn i {
                width: 24px;
                text-align: center;
                margin-right: 8px;
            }

        /* Panel Content */
        .panel {
            background: #fff;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            min-height: 400px;
        }

            .panel h3 {
                margin-top: 0;
                margin-bottom: 20px;
                padding-bottom: 10px;
                border-bottom: 1px solid #eee;
                font-size: 20px;
            }

        .form-group {
            margin-bottom: 16px;
        }

        .form-label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            font-size: 14px;
        }

        .form-control {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
        }

        .btn-save {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
        }

            .btn-save:hover {
                background: #c0392b;
            }

        /* Order List */
        .order-item {
            border: 1px solid #eee;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .order-status {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .status-PENDING {
            background: #fff3cd;
            color: #856404;
        }

        .status-CONFIRMED {
            background: #d1e7dd;
            color: #0f5132;
        }

        .status-CANCELLED {
            background: #f8d7da;
            color: #842029;
        }

        .alert-success {
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 15px;
        }

        .alert-danger {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 15px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="account-wrap">
        <div class="account-grid">
            <aside class="sidebar">
                <div class="user-mini">
                    <img src="https://i.pravatar.cc/150?img=12" class="avatar-sm" alt="Avatar">
                    <div>
                        <div style="font-weight: 700">
                            <asp:Literal ID="litSidebarName" runat="server"></asp:Literal>
                        </div>
                        <div style="font-size: 12px; color: #777">Thành viên</div>
                    </div>
                </div>

                <nav>
                    <asp:LinkButton ID="btnNavProfile" runat="server" CssClass="nav-btn active" OnClick="SwitchTab_Click" CommandArgument="Profile">
                        <i class="fas fa-user"></i> Thông tin cá nhân
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnNavOrders" runat="server" CssClass="nav-btn" OnClick="SwitchTab_Click" CommandArgument="Orders">
                        <i class="fas fa-receipt"></i> Lịch sử đơn hàng
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnNavPassword" runat="server" CssClass="nav-btn" OnClick="SwitchTab_Click" CommandArgument="Password">
                        <i class="fas fa-lock"></i> Đổi mật khẩu
                    </asp:LinkButton>
                    <hr style="margin: 10px 0; border: 0; border-top: 1px solid #eee;">
                    <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-btn" OnClick="btnLogout_Click" Style="color: #e74c3c;">
    <i class="fas fa-sign-out-alt"></i> Đăng xuất
</asp:LinkButton>
                </nav>
            </aside>

            <section class="panel">
                <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                    <asp:Label ID="lblMessage" runat="server"></asp:Label>
                </asp:Panel>

                <asp:MultiView ID="mvAccount" runat="server" ActiveViewIndex="0">
                    <asp:View ID="vProfile" runat="server">
                        <h3>Thông tin cá nhân</h3>
                        <div class="form-group">
                            <label class="form-label">Họ và tên</label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Số điện thoại</label>
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" ReadOnly="true" ToolTip="Không thể thay đổi SĐT đăng nhập" Style="background: #f5f5f5"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Email</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="example@gmail.com"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Địa chỉ (Mặc định)</label>
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" placeholder="Chưa lưu trong database" Enabled="false"></asp:TextBox>
                        </div>

                        <div style="margin-top: 20px;">
                            <asp:Button ID="btnSaveProfile" runat="server" Text="Lưu thay đổi" CssClass="btn-save" OnClick="btnSaveProfile_Click" />
                        </div>
                    </asp:View>

                    <asp:View ID="vOrders" runat="server">
                        <h3>Đơn hàng của tôi</h3>
                        <asp:Repeater ID="rptOrders" runat="server">
                            <ItemTemplate>
                                <div class="order-item">
                                    <div>
                                        <div style="font-weight: bold; margin-bottom: 4px">Đơn hàng #<%# Eval("order_id") %></div>
                                        <div style="font-size: 13px; color: #666">
                                            Ngày: <%# Eval("order_time", "{0:dd/MM/yyyy HH:mm}") %>
                                            <span style="margin: 0 5px">•</span>
                                            <%# Eval("item_count") %> món
                                        </div>
                                    </div>
                                    <div style="text-align: right">
                                        <div style="font-weight: bold; color: #e74c3c"><%# Eval("total_amount", "{0:N0} đ") %></div>
                                        <div class="order-status status-<%# Eval("status") %>" style="margin-top: 4px; display: inline-block">
                                            <%# Eval("status") %>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:Label ID="lblNoOrder" runat="server" Text="Bạn chưa có đơn hàng nào." Visible='<%# rptOrders.Items.Count == 0 %>' Style="color: #777; font-style: italic;"></asp:Label>
                            </FooterTemplate>
                        </asp:Repeater>
                    </asp:View>

                    <asp:View ID="vPassword" runat="server">
                        <h3>Đổi mật khẩu</h3>
                        <div class="form-group">
                            <label class="form-label">Mật khẩu hiện tại</label>
                            <asp:TextBox ID="txtOldPass" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Mật khẩu mới</label>
                            <asp:TextBox ID="txtNewPass" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Nhập lại mật khẩu mới</label>
                            <asp:TextBox ID="txtConfirmPass" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                            <asp:CompareValidator ID="cvPass" runat="server" ControlToValidate="txtConfirmPass" ControlToCompare="txtNewPass" ErrorMessage="Mật khẩu nhập lại không khớp" ForeColor="Red" Display="Dynamic"></asp:CompareValidator>
                        </div>
                        <div style="margin-top: 20px;">
                            <asp:Button ID="btnChangePass" runat="server" Text="Cập nhật mật khẩu" CssClass="btn-save" OnClick="btnChangePass_Click" />
                        </div>
                    </asp:View>
                </asp:MultiView>
            </section>
        </div>
    </div>
</asp:Content>
