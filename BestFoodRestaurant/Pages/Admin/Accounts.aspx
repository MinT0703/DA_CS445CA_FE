<%@ Page Title="Quản lý Tài khoản" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Accounts.aspx.cs" Inherits="BestFoodRestaurant.Pages.Admin.Accounts" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .table-wrap { overflow-x: auto; padding-bottom: 20px; }
        .admin-table { width: 100%; border-collapse: collapse; min-width: 900px; }
        .admin-table th, .admin-table td { padding: 12px 15px; border-bottom: 1px solid #eee; text-align: left; vertical-align: middle; }
        .admin-table th { background: #f8f9fa; color: #666; font-weight: 600; font-size: 13px; text-transform: uppercase; }
        
        /* --- FIX LỖI CSS ROLE --- */
        .role-badge { 
            padding: 5px 10px; 
            border-radius: 4px; 
            font-size: 11px; 
            font-weight: 700; 
            color: #fff; 
            text-transform: uppercase;
            white-space: nowrap; /* Giữ chữ trên 1 dòng */
            display: inline-block;
            min-width: 80px;
            text-align: center;
        }
        /* Màu sắc cho từng Role */
        .role-admin { background: #e74c3c; }      /* Đỏ */
        .role-manager { background: #f39c12; }    /* Cam */
        .role-chef { background: #9b59b6; }       /* Tím */
        .role-staff { background: #3498db; }      /* Xanh dương */
        .role-customer { background: #2ecc71; }   /* Xanh lá */
        
        .status-active { color: #2ecc71; font-weight: 600; }
        .status-locked { color: #95a5a6; font-weight: 600; text-decoration: line-through; }

        /* Modal Styles */
        .modal-backdrop { 
            position: fixed; top: 0; left: 0; right: 0; bottom: 0; 
            background: rgba(0,0,0,0.5); z-index: 999; 
            display: none; align-items: center; justify-content: center; 
        }
        .modal-content { 
            background: #fff; width: 500px; max-width: 90%; 
            padding: 25px; border-radius: 12px; box-shadow: 0 5px 20px rgba(0,0,0,0.2); 
        }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 600; font-size: 13px; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; }
        .modal-footer { margin-top: 20px; text-align: right; display: flex; gap: 10px; justify-content: flex-end; }
        
        .pagination { display: flex; gap: 5px; justify-content: flex-end; margin-top: 20px; }
        .page-item { padding: 6px 12px; border: 1px solid #ddd; border-radius: 4px; color: #333; text-decoration: none; }
        .page-item.active { background: #e74c3c; color: #fff; border-color: #e74c3c; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="card-panel" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
        <div>
            <h2 style="margin: 0;">Quản lý Tài khoản</h2>
            <p class="muted small" style="margin: 5px 0 0;">Quản lý thành viên và phân quyền hệ thống.</p>
        </div>
        <div style="display: flex; gap: 10px;">
            <asp:Button ID="btnExport" runat="server" Text="Xuất CSV" CssClass="btn" style="background:#27ae60; color:#fff;" OnClick="btnExport_Click" />
            <button type="button" class="btn" style="background:var(--primary-color); color:#fff;" onclick="openAddModal()">+ Thêm mới</button>
        </div>
    </div>

    <div class="card-panel">
        <div style="display: flex; gap: 10px; margin-bottom: 20px; flex-wrap: wrap;">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" Placeholder="Tìm tên, email..." style="width: 250px; display:inline-block;"></asp:TextBox>
            
            <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="form-control" style="width: 180px; display:inline-block;">
                <asp:ListItem Value="">-- Tất cả vai trò --</asp:ListItem>
                <asp:ListItem Value="5">Admin (Quản trị)</asp:ListItem>
                <asp:ListItem Value="4">Manager (Quản lý)</asp:ListItem>
                <asp:ListItem Value="3">Chef (Đầu bếp)</asp:ListItem>
                <asp:ListItem Value="2">Staff (Nhân viên)</asp:ListItem>
                <asp:ListItem Value="1">Customer (Khách)</asp:ListItem>
            </asp:DropDownList>

            <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn" style="background:#34495e; color:#fff;" OnClick="btnSearch_Click" />
        </div>

        <div class="table-wrap">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Họ tên</th>
                        <th>Liên hệ</th>
                        <th>Vai trò</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td>#<%# Eval("user_id") %></td>
                                <td>
                                    <div style="font-weight: 600; color:#2c3e50;"><%# Eval("full_name") %></div>
                                    <div class="muted small" style="font-size:11px">Tạo: <%# Eval("created_at", "{0:dd/MM/yyyy}") %></div>
                                </td>
                                <td>
                                    <div style="font-size:13px"><i class="fas fa-envelope muted"></i> <%# Eval("email") %></div>
                                    <div class="small muted"><i class="fas fa-phone muted"></i> <%# Eval("phone") %></div>
                                </td>
                                <td>
                                    <span class='<%# GetRoleBadgeClass(Eval("role_id")) %>'>
                                        <%# GetRoleName(Eval("role_id")) %>
                                    </span>
                                </td>
                                <td>
                                    <span class='<%# Eval("status").ToString() == "ACTIVE" ? "status-active" : "status-locked" %>'>
                                        <%# Eval("status").ToString() == "ACTIVE" ? "Hoạt động" : "Đã khóa" %>
                                    </span>
                                </td>
                                <td>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditUser" CommandArgument='<%# Eval("user_id") %>' ToolTip="Sửa" style="color:#f39c12; margin-right:8px; font-size:16px;">
                                        <i class="fas fa-pen"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnLock" runat="server" CommandName="ToggleLock" CommandArgument='<%# Eval("user_id") %>' ToolTip="Khóa/Mở" style="color:#95a5a6; margin-right:8px; font-size:16px;" OnClientClick="return confirm('Bạn muốn đổi trạng thái tài khoản này?');">
                                        <i class="fas fa-lock"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteUser" CommandArgument='<%# Eval("user_id") %>' ToolTip="Xóa" style="color:#e74c3c; font-size:16px;" OnClientClick="return confirm('CẢNH BÁO QUAN TRỌNG:\n\nHành động này sẽ xóa vĩnh viễn:\n- Tài khoản người dùng\n- Lịch sử đặt bàn\n- Lịch sử đơn hàng\n\nBạn có chắc chắn muốn xóa không?');">
                                        <i class="fas fa-trash"></i>
                                    </asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
            
            <div style="text-align: center; padding: 30px;" id="divNoData" runat="server" visible="false">
                <p class="muted">Không tìm thấy tài khoản nào phù hợp.</p>
            </div>
        </div>
        
        <div class="pagination">
            <asp:Literal ID="litPagination" runat="server"></asp:Literal>
        </div>
    </div>

    <div id="userModal" class="modal-backdrop" runat="server" clientidmode="Static">
        <div class="modal-content">
            <h3 id="modalTitle" style="margin-top:0;">Thêm tài khoản mới</h3>
            
            <asp:HiddenField ID="hdfUserId" runat="server" ClientIDMode="Static" />
            
            <div class="form-group">
                <label>Họ và tên</label>
                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" ClientIDMode="Static"></asp:TextBox>
            </div>
            
            <div class="form-group">
                <label>Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" ClientIDMode="Static"></asp:TextBox>
            </div>

            <div class="form-group">
                <label>Số điện thoại</label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" ClientIDMode="Static"></asp:TextBox>
            </div>

            <div class="form-group">
                <label>Mật khẩu</label>
                <asp:TextBox ID="txtPass" runat="server" CssClass="form-control" TextMode="Password" placeholder="Để trống nếu không muốn đổi" ClientIDMode="Static"></asp:TextBox>
            </div>

            <div class="form-group">
                <label>Vai trò</label>
                <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-control" ClientIDMode="Static">
                    <asp:ListItem Value="1">Customer (Khách hàng)</asp:ListItem>
                    <asp:ListItem Value="2">Staff (Nhân viên)</asp:ListItem>
                    <asp:ListItem Value="3">Chef (Đầu bếp)</asp:ListItem>
                    <asp:ListItem Value="4">Manager (Quản lý)</asp:ListItem>
                    <asp:ListItem Value="5">Admin (Quản trị viên)</asp:ListItem>
                </asp:DropDownList>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn" style="background:#eee; color:#333;" onclick="closeModal()">Hủy</button>
                <asp:Button ID="btnSave" runat="server" Text="Lưu lại" CssClass="btn" style="background:#e74c3c; color:#fff;" OnClick="btnSave_Click" />
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        function openAddModal() {
            var modal = document.getElementById('userModal');
            if (modal) {
                modal.style.display = 'flex';
                document.getElementById('modalTitle').innerText = 'Thêm tài khoản mới';

                // Reset form
                if (document.getElementById('hdfUserId')) document.getElementById('hdfUserId').value = '';
                if (document.getElementById('txtName')) document.getElementById('txtName').value = '';
                if (document.getElementById('txtEmail')) document.getElementById('txtEmail').value = '';
                if (document.getElementById('txtPhone')) document.getElementById('txtPhone').value = '';
                if (document.getElementById('txtPass')) document.getElementById('txtPass').value = '';
                if (document.getElementById('ddlRole')) document.getElementById('ddlRole').value = '1';
            }
        }

        function showEditModal() {
            var modal = document.getElementById('userModal');
            if (modal) {
                modal.style.display = 'flex';
                document.getElementById('modalTitle').innerText = 'Cập nhật thông tin';
            }
        }

        function closeModal() {
            var modal = document.getElementById('userModal');
            if (modal) modal.style.display = 'none';
        }
    </script>
</asp:Content>