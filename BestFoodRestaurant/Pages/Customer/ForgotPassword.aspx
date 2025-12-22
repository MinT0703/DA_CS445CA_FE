<%@ Page Title="Quên mật khẩu" Language="C#" MasterPageFile="~/MasterPages/Customer.Master" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="BestFoodRestaurant.Pages.Customer.ForgotPassword" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Quên mật khẩu - BestFood
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Styles" runat="server">
    <style>
        .forgot-wrap {
            min-height: calc(100vh - 160px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            background: #f9f9f9;
        }

        .forgot-card {
            max-width: 420px;
            width: 100%;
            background: #fff;
            border-radius: 16px;
            padding: 32px 28px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
            text-align: center;
        }

        .forgot-card h2 {
            margin: 0 0 10px;
            font-size: 24px;
            color: #e74c3c;
            font-weight: 700;
        }

        .muted {
            color: #666;
            font-size: 14px;
            margin-bottom: 24px;
            line-height: 1.5;
        }

        .form-group { margin-bottom: 20px; text-align: left; }
        
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

        .btn-submit {
            width: 100%;
            padding: 12px;
            background: #e74c3c;
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-submit:hover {
            background: #c0392b;
            transform: translateY(-2px);
        }

        .back-link {
            display: block;
            margin-top: 20px;
            font-size: 14px;
            color: #666;
            text-decoration: none;
        }
        .back-link:hover { color: #e74c3c; text-decoration: underline; }

        .alert-box {
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            text-align: left;
        }
        .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="forgot-wrap">
        <div class="forgot-card">
            <h2>Quên mật khẩu?</h2>
            <p class="muted">Nhập email hoặc số điện thoại bạn đã đăng ký. Chúng tôi sẽ gửi hướng dẫn đặt lại mật khẩu.</p>

            <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </asp:Panel>

            <div class="form-group">
                <asp:TextBox ID="txtIdentity" runat="server" CssClass="form-control" placeholder="Email hoặc Số điện thoại"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvIdentity" runat="server" ControlToValidate="txtIdentity" ErrorMessage="Vui lòng nhập thông tin" Display="Dynamic" ForeColor="#e74c3c" Font-Size="13px" style="margin-top:5px;display:block"></asp:RequiredFieldValidator>
            </div>

            <asp:Button ID="btnSubmit" runat="server" Text="Gửi yêu cầu" CssClass="btn-submit" OnClick="btnSubmit_Click" />

            <asp:HyperLink ID="lnkLogin" runat="server" NavigateUrl="Login.aspx" CssClass="back-link">
                <i class="fas fa-arrow-left"></i> Quay lại Đăng nhập
            </asp:HyperLink>
        </div>
    </div>
</asp:Content>