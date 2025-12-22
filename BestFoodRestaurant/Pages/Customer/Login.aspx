<%@ Page Title="Đăng nhập" Language="C#" MasterPageFile="~/MasterPages/Customer.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="BestFoodRestaurant.Pages.Customer.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Đăng nhập - BestFood
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Styles" runat="server">
    <style>
        .login-wrap {
            min-height: calc(100vh - 160px); /* Trừ header/footer */
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            background: #f9f9f9;
        }

        .login-card {
            max-width: 420px;
            width: 100%;
            background: #fff;
            border-radius: 16px;
            padding: 32px 28px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
        }

        .login-card h2 {
            margin: 0 0 8px;
            text-align: center;
            font-size: 26px;
            color: #e74c3c;
            font-weight: 700;
        }

        .muted { 
            text-align: center; 
            margin-bottom: 24px; 
            color: #6b7280; 
            font-size: 14px; 
        }

        .form-group { margin-bottom: 16px; }
        
        .form-group label { 
            display: block; 
            margin-bottom: 8px; 
            font-weight: 600; 
            font-size: 14px; 
            color: #333;
        }

        .form-control { 
            width: 100%; 
            padding: 12px 14px; 
            border: 1px solid #d1d5db; 
            border-radius: 10px; 
            font-size: 15px;
            transition: all 0.2s;
        }
        .form-control:focus { 
            outline: none; 
            border-color: #e74c3c; 
            box-shadow: 0 0 0 3px rgba(231,76,60,.15); 
        }

        .btn-login {
            width: 100%;
            padding: 14px;
            background: #e74c3c;
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all .3s;
            margin-top: 10px;
        }
        .btn-login:hover { 
            background: #c0392b; 
            transform: translateY(-2px); 
            box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
        }

        /* --- SỬA LỖI GHI NHỚ TÔI --- */
        .extra-links {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 16px 0 24px;
            font-size: 14px;
        }

        /* Class riêng cho nhãn checkbox */
        .remember-label {
            display: flex;
            align-items: center;
            gap: 8px; /* Khoảng cách giữa ô vuông và chữ */
            cursor: pointer;
            user-select: none;
            color: #333;
            white-space: nowrap; /* Quan trọng: Ngăn chữ bị xuống dòng */
        }
        
        .remember-label input[type="checkbox"] {
            width: 16px; 
            height: 16px;
            cursor: pointer;
            accent-color: #e74c3c; /* Màu checkbox */
            margin: 0;
        }

        .forgot-link { 
            color: #e74c3c; 
            text-decoration: none; 
            font-weight: 600; 
        }
        .forgot-link:hover { text-decoration: underline; }
        
        .error-message {
            color: #b91c1c;
            background: #fef2f2;
            padding: 12px;
            border: 1px solid #fecaca;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            text-align: center;
            display: block;
        }

        .register-link {
            text-align: center;
            margin-top: 20px;
            font-size: 14px;
            color: #666;
        }
        .register-link a {
            color: #e74c3c;
            font-weight: 700;
            text-decoration: none;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="login-wrap">
        <div class="login-card">
            <h2>Đăng nhập</h2>
            <p class="muted">Chào mừng quay lại BestFood!</p>

            <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="error-message">
                <i class="fas fa-exclamation-circle"></i> <asp:Label ID="lblError" runat="server"></asp:Label>
            </asp:Panel>

            <div class="form-group">
                <label>Email hoặc Số điện thoại</label>
                <asp:TextBox ID="txtIdentity" runat="server" CssClass="form-control" placeholder="you@example.com hoặc 0912345678"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvIdentity" runat="server" ControlToValidate="txtIdentity" ErrorMessage="Vui lòng nhập thông tin" Display="Dynamic" ForeColor="#e74c3c" Font-Size="12px" style="margin-top:4px;display:block"></asp:RequiredFieldValidator>
            </div>

            <div class="form-group">
                <label>Mật khẩu</label>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Nhập mật khẩu"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvPass" runat="server" ControlToValidate="txtPassword" ErrorMessage="Vui lòng nhập mật khẩu" Display="Dynamic" ForeColor="#e74c3c" Font-Size="12px" style="margin-top:4px;display:block"></asp:RequiredFieldValidator>
            </div>

            <div class="extra-links">
                <label class="remember-label">
                    <asp:CheckBox ID="chkRemember" runat="server" />
                    <span>Ghi nhớ tôi</span>
                </label>
                <asp:HyperLink ID="lnkForgot" runat="server" NavigateUrl="ForgotPassword.aspx" CssClass="forgot-link">Quên mật khẩu?</asp:HyperLink>
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="Đăng nhập" CssClass="btn-login" OnClick="btnLogin_Click" />

            <div class="register-link">
                Chưa có tài khoản? <asp:HyperLink ID="lnkRegister" runat="server" NavigateUrl="Register.aspx">Đăng ký ngay</asp:HyperLink>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="Scripts" runat="server">
</asp:Content>