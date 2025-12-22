<%@ Page Title="Đăng ký" Language="C#" MasterPageFile="~/MasterPages/Customer.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="BestFoodRestaurant.Pages.Customer.Register" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Đăng ký - BestFood
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Styles" runat="server">
    <style>
        .register-wrap {
            min-height: calc(100vh - 80px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            background: #f9f9f9;
        }

        .register-card {
            max-width: 500px;
            width: 100%;
            background: #fff;
            border-radius: 16px;
            padding: 32px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.08);
        }

        .register-card h1 {
            margin: 0 0 10px;
            text-align: center;
            font-size: 26px;
            color: #e74c3c;
        }

        .muted { text-align: center; margin-bottom: 20px; color: #6b7280; font-size: 14px; }

        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 6px; font-weight: 600; font-size: 14px; }
        .form-control { width: 100%; padding: 10px 14px; border: 1px solid #d1d5db; border-radius: 10px; font-size: 15px; }
        
        .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }

        /* Avatar Upload Style */
        .avatar-upload { display: flex; align-items: center; gap: 12px; }
        .avatar-preview { width: 60px; height: 60px; border-radius: 8px; object-fit: cover; border: 2px solid #f3f4f6; }

        .btn-register {
            width: 100%;
            padding: 14px;
            background: #e74c3c;
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
            transition: all .3s;
        }
        .btn-register:hover { background: #c0392b; transform: translateY(-2px); }

        .error-msg { color: #ef4444; font-size: 12px; display: block; margin-top: 4px; }
        .alert-box { padding: 10px; border-radius: 8px; margin-bottom: 15px; font-size: 14px; display: none; }
        .alert-error { background: #fee2e2; color: #991b1b; display: block; }
        .alert-success { background: #dcfce7; color: #166534; display: block; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="register-wrap">
        <section class="register-card">
            <h1>Tạo tài khoản</h1>
            <p class="muted">Tham gia ngay để nhận ưu đãi</p>

            <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </asp:Panel>

            <div class="form-group">
                <label>Ảnh đại diện (Tùy chọn)</label>
                <div class="avatar-upload">
                    <img id="imgPreview" src="https://i.pravatar.cc/150?img=7" class="avatar-preview" alt="Preview" />
                    <asp:FileUpload ID="fuAvatar" runat="server" onchange="previewImage(this)" />
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label>Họ và tên <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Nguyễn Văn A"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Nhập họ tên" CssClass="error-msg" Display="Dynamic" ValidationGroup="Reg"></asp:RequiredFieldValidator>
                </div>
                <div class="form-group">
                    <label>Số điện thoại <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="0912345678"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="Nhập SĐT" CssClass="error-msg" Display="Dynamic" ValidationGroup="Reg"></asp:RequiredFieldValidator>
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label>Mật khẩu <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Tối thiểu 6 ký tự"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvPass" runat="server" ControlToValidate="txtPassword" ErrorMessage="Nhập mật khẩu" CssClass="error-msg" Display="Dynamic" ValidationGroup="Reg"></asp:RequiredFieldValidator>
                </div>
                <div class="form-group">
                    <label>Xác nhận mật khẩu</label>
                    <asp:TextBox ID="txtConfirm" runat="server" CssClass="form-control" TextMode="Password" placeholder="Nhập lại"></asp:TextBox>
                    <asp:CompareValidator ID="cvPass" runat="server" ControlToValidate="txtConfirm" ControlToCompare="txtPassword" ErrorMessage="Không khớp" CssClass="error-msg" Display="Dynamic" ValidationGroup="Reg"></asp:CompareValidator>
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label>Ngày sinh</label>
                    <asp:TextBox ID="txtDob" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Địa chỉ</label>
                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" placeholder="Quận/Huyện, TP"></asp:TextBox>
                </div>
            </div>

            <asp:Button ID="btnRegister" runat="server" Text="Đăng ký" CssClass="btn-register" OnClick="btnRegister_Click" ValidationGroup="Reg" />
            
            <p style="text-align:center;margin-top:14px">Đã có tài khoản? 
                <asp:HyperLink ID="lnkLogin" runat="server" NavigateUrl="Login.aspx" style="color:#e74c3c;font-weight:600;text-decoration:none">Đăng nhập</asp:HyperLink>
            </p>
        </section>
    </div>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        function previewImage(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    document.getElementById('imgPreview').src = e.target.result;
                }
                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>
</asp:Content>