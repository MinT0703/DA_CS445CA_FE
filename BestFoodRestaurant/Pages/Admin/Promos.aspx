<%@ Page Title="Quản lý Khuyến mãi" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Promos.aspx.cs" Inherits="BestFoodRestaurant.Pages.Admin.Promos" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .table-wrap { overflow-x: auto; padding-bottom: 20px; }
        .admin-table { width: 100%; border-collapse: collapse; min-width: 900px; }
        .admin-table th, .admin-table td { padding: 12px 15px; border-bottom: 1px solid #eee; text-align: left; vertical-align: middle; }
        .admin-table th { background: #f8f9fa; color: #666; font-weight: 600; font-size: 13px; text-transform: uppercase; }

        .code-badge { font-family: monospace; font-weight: bold; background: #fdf2f2; color: #c0392b; padding: 4px 8px; border: 1px dashed #e74c3c; border-radius: 4px; font-size: 14px; }
        
        .status-active { color: #2ecc71; font-weight: 600; background: rgba(46, 204, 113, 0.1); padding: 4px 8px; border-radius: 4px; font-size: 12px; }
        .status-expired { color: #e74c3c; font-weight: 600; background: rgba(231, 76, 60, 0.1); padding: 4px 8px; border-radius: 4px; font-size: 12px; }
        .status-inactive { color: #95a5a6; font-weight: 600; background: #eee; padding: 4px 8px; border-radius: 4px; font-size: 12px; }

        /* Modal Styles */
        .modal-backdrop { 
            position: fixed; top: 0; left: 0; right: 0; bottom: 0; 
            background: rgba(0,0,0,0.5); z-index: 999; 
            display: none; align-items: center; justify-content: center; 
        }
        .modal-content { 
            background: #fff; width: 600px; max-width: 95%; 
            padding: 25px; border-radius: 12px; box-shadow: 0 5px 20px rgba(0,0,0,0.2); 
        }
        
        .form-row { display: flex; gap: 15px; }
        .form-group { margin-bottom: 15px; flex: 1; }
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
            <h2 style="margin: 0;">Quản lý Voucher</h2>
            <p class="muted small" style="margin: 5px 0 0;">Tạo mã giảm giá và chương trình khuyến mãi.</p>
        </div>
        <div style="display: flex; gap: 10px;">
            <button type="button" class="btn" style="background:var(--primary-color); color:#fff;" onclick="openAddModal()">+ Thêm Voucher</button>
        </div>
    </div>

    <div class="card-panel">
        <div style="display: flex; gap: 10px; margin-bottom: 20px; flex-wrap: wrap;">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" Placeholder="Tìm mã code..." style="width: 250px; display:inline-block;"></asp:TextBox>
            
            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-control" style="width: 180px; display:inline-block;">
                <asp:ListItem Value="">-- Tất cả trạng thái --</asp:ListItem>
                <asp:ListItem Value="1">Đang chạy</asp:ListItem>
                <asp:ListItem Value="0">Đã tắt</asp:ListItem>
                <asp:ListItem Value="EXPIRED">Đã hết hạn</asp:ListItem>
            </asp:DropDownList>

            <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn" style="background:#34495e; color:#fff;" OnClick="btnSearch_Click" />
        </div>

        <div class="table-wrap">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Mã Code</th>
                        <th>Chi tiết giảm giá</th>
                        <th>Điều kiện</th>
                        <th>Thời gian áp dụng</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptPromos" runat="server" OnItemCommand="rptPromos_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td><span class="code-badge"><%# Eval("code") %></span></td>
                                <td>
                                    <div style="font-weight:600; color:#e74c3c">
                                        <%# FormatDiscount(Eval("discount_type"), Eval("discount_value")) %>
                                    </div>
                                    <div class="small muted"><%# Eval("description") %></div>
                                </td>
                                <td class="small">
                                    Đơn tối thiểu: <br />
                                    <b><%# Eval("min_order_value", "{0:N0} đ") %></b>
                                </td>
                                <td class="small">
                                    <%# Eval("start_date", "{0:dd/MM/yy}") %> - <%# Eval("end_date", "{0:dd/MM/yy}") %>
                                </td>
                                <td>
                                    <%# GetStatusBadge(Eval("is_active"), Eval("end_date")) %>
                                </td>
                                <td>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditPromo" CommandArgument='<%# Eval("promo_id") %>' ToolTip="Sửa" style="color:#f39c12; margin-right:8px; font-size:16px;">
                                        <i class="fas fa-pen"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeletePromo" CommandArgument='<%# Eval("promo_id") %>' ToolTip="Xóa" style="color:#e74c3c; font-size:16px;" OnClientClick="return confirm('Bạn có chắc chắn muốn xóa mã giảm giá này?');">
                                        <i class="fas fa-trash"></i>
                                    </asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
            
            <div style="text-align: center; padding: 30px;" id="divNoData" runat="server" visible="false">
                <p class="muted">Không tìm thấy mã giảm giá nào.</p>
            </div>
        </div>
    </div>

    <div id="promoModal" class="modal-backdrop" runat="server" clientidmode="Static">
        <div class="modal-content">
            <h3 id="modalTitle" style="margin-top:0;">Thêm Voucher Mới</h3>
            
            <asp:HiddenField ID="hdfPromoId" runat="server" ClientIDMode="Static" />
            
            <div class="form-row">
                <div class="form-group">
                    <label>Mã Code <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtCode" runat="server" CssClass="form-control" style="text-transform:uppercase; font-weight:bold;" ClientIDMode="Static"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Trạng thái</label>
                    <asp:DropDownList ID="ddlActive" runat="server" CssClass="form-control" ClientIDMode="Static">
                        <asp:ListItem Value="1">Kích hoạt</asp:ListItem>
                        <asp:ListItem Value="0">Tắt</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <div class="form-group">
                <label>Mô tả ngắn</label>
                <asp:TextBox ID="txtDesc" runat="server" CssClass="form-control" ClientIDMode="Static"></asp:TextBox>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Loại giảm giá</label>
                    <asp:DropDownList ID="ddlType" runat="server" CssClass="form-control" ClientIDMode="Static">
                        <asp:ListItem Value="PERCENT">Theo phần trăm (%)</asp:ListItem>
                        <asp:ListItem Value="FIXED">Theo số tiền (VNĐ)</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="form-group">
                    <label>Giá trị giảm <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtValue" runat="server" CssClass="form-control" TextMode="Number" ClientIDMode="Static"></asp:TextBox>
                </div>
            </div>

            <div class="form-group">
                <label>Đơn hàng tối thiểu (VNĐ)</label>
                <asp:TextBox ID="txtMinOrder" runat="server" CssClass="form-control" TextMode="Number" ClientIDMode="Static"></asp:TextBox>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Ngày bắt đầu</label>
                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date" ClientIDMode="Static"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Ngày kết thúc</label>
                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date" ClientIDMode="Static"></asp:TextBox>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn" style="background:#eee; color:#333;" onclick="closeModal()">Hủy</button>
                <asp:Button ID="btnSave" runat="server" Text="Lưu Voucher" CssClass="btn" style="background:#e74c3c; color:#fff;" OnClick="btnSave_Click" />
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        function openAddModal() {
            var m = document.getElementById('promoModal');
            if (m) {
                m.style.display = 'flex';
                document.getElementById('modalTitle').innerText = 'Thêm Voucher Mới';

                // Reset form
                document.getElementById('hdfPromoId').value = '';
                document.getElementById('txtCode').value = '';
                document.getElementById('txtDesc').value = '';
                document.getElementById('txtValue').value = '';
                document.getElementById('txtMinOrder').value = '0';

                // Set default dates (Today -> Next Month)
                var today = new Date().toISOString().split('T')[0];
                document.getElementById('txtStartDate').value = today;
                document.getElementById('txtEndDate').value = "";
            }
        }

        function showEditModal() {
            var m = document.getElementById('promoModal');
            if (m) {
                m.style.display = 'flex';
                document.getElementById('modalTitle').innerText = 'Cập nhật Voucher';
            }
        }

        function closeModal() {
            document.getElementById('promoModal').style.display = 'none';
        }
    </script>
</asp:Content>