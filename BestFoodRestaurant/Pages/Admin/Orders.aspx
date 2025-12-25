<%@ Page Title="Quản lý Đơn hàng" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Orders.aspx.cs" Inherits="BestFoodRestaurant.Pages.Admin.Orders" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .table-wrap { overflow-x: auto; padding-bottom: 20px; }
        .admin-table { width: 100%; border-collapse: collapse; min-width: 900px; }
        .admin-table th, .admin-table td { padding: 12px 15px; border-bottom: 1px solid #eee; text-align: left; vertical-align: middle; }
        .admin-table th { background: #f8f9fa; color: #666; font-weight: 600; font-size: 13px; text-transform: uppercase; }

        /* Status Badges */
        .status-badge { padding: 5px 10px; border-radius: 20px; font-size: 11px; font-weight: 700; color: #fff; white-space: nowrap; display: inline-block; }
        .st-pending { background: #f39c12; }   /* Chờ xác nhận (Cam) */
        .st-confirmed { background: #3498db; } /* Đã xác nhận (Xanh dương) */
        .st-preparing { background: #e67e22; } /* Đang chuẩn bị (Cam đậm) */
        .st-delivering { background: #1abc9c; }/* Đang giao (Xanh ngọc) */
        .st-completed { background: #2ecc71; } /* Hoàn thành (Xanh lá) */
        .st-cancelled { background: #95a5a6; } /* Đã hủy (Xám) */

        /* Modal Styles */
        .modal-backdrop { 
            position: fixed; top: 0; left: 0; right: 0; bottom: 0; 
            background: rgba(0,0,0,0.5); z-index: 999; 
            display: none; align-items: center; justify-content: center; 
        }
        .modal-content { 
            background: #fff; width: 700px; max-width: 95%; 
            padding: 25px; border-radius: 12px; box-shadow: 0 5px 20px rgba(0,0,0,0.2); 
            max-height: 90vh; overflow-y: auto;
        }
        
        .invoice-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .invoice-table th, .invoice-table td { border-bottom: 1px solid #eee; padding: 8px; font-size: 14px; }
        .invoice-header { display: flex; justify-content: space-between; margin-bottom: 20px; border-bottom: 2px dashed #eee; padding-bottom: 15px; }
        
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 600; font-size: 13px; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; }
        
        .pagination { display: flex; gap: 5px; justify-content: flex-end; margin-top: 20px; }
        .page-item { padding: 6px 12px; border: 1px solid #ddd; border-radius: 4px; color: #333; text-decoration: none; }
        .page-item.active { background: #e74c3c; color: #fff; border-color: #e74c3c; }

        @media print {
            body * { visibility: hidden; }
            #invoice-area, #invoice-area * { visibility: visible; }
            #invoice-area { position: absolute; left: 0; top: 0; width: 100%; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="card-panel" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
        <div>
            <h2 style="margin: 0;">Quản lý Đơn hàng</h2>
            <p class="muted small" style="margin: 5px 0 0;">Theo dõi và cập nhật trạng thái đơn hàng.</p>
        </div>
        <div>
            <asp:Button ID="btnExport" runat="server" Text="Xuất CSV" CssClass="btn" style="background:#27ae60; color:#fff;" OnClick="btnExport_Click" />
        </div>
    </div>

    <div class="card-panel">
        <div style="display: flex; gap: 10px; margin-bottom: 20px; flex-wrap: wrap;">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" Placeholder="Mã đơn, tên khách..." style="width: 220px; display:inline-block;"></asp:TextBox>
            
            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-control" style="width: 160px; display:inline-block;">
                <asp:ListItem Value="">-- Tất cả trạng thái --</asp:ListItem>
                <asp:ListItem Value="PENDING">Chờ xác nhận</asp:ListItem>
                <asp:ListItem Value="CONFIRMED">Đã xác nhận</asp:ListItem>
                <asp:ListItem Value="PREPARING">Đang chuẩn bị</asp:ListItem>
                <asp:ListItem Value="DELIVERING">Đang giao hàng</asp:ListItem>
                <asp:ListItem Value="COMPLETED">Hoàn thành</asp:ListItem>
                <asp:ListItem Value="CANCELLED">Đã hủy</asp:ListItem>
            </asp:DropDownList>

            <asp:DropDownList ID="ddlPaymentFilter" runat="server" CssClass="form-control" style="width: 160px; display:inline-block;">
                <asp:ListItem Value="">-- Thanh toán --</asp:ListItem>
                <asp:ListItem Value="CASH">Tiền mặt (COD)</asp:ListItem>
                <asp:ListItem Value="CARD">Chuyển khoản/Thẻ</asp:ListItem>
            </asp:DropDownList>

            <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn" style="background:#34495e; color:#fff;" OnClick="btnSearch_Click" />
        </div>

        <div class="table-wrap">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Mã Đơn</th>
                        <th>Khách hàng</th>
                        <th>Tổng tiền</th>
                        <th>Thanh toán</th>
                        <th>Trạng thái</th>
                        <th>Ngày đặt</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptOrders" runat="server" OnItemCommand="rptOrders_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:bold">#<%# Eval("order_id") %></td>
                                <td>
                                    <div style="font-weight: 600;"><%# Eval("full_name") %></div>
                                    <div class="muted small"><i class="fas fa-phone"></i> <%# Eval("phone") %></div>
                                </td>
                                <td style="font-weight: bold; color: #e74c3c;"><%# Eval("total_amount", "{0:N0} đ") %></td>
                                <td>
                                    <span style="font-size:12px; font-weight:600; color:#555;">
                                        <%# GetPaymentMethodName(Eval("payment_method")) %>
                                    </span>
                                </td>
                                <td>
                                    <%# GetStatusBadge(Eval("status")) %>
                                </td>
                                <td class="small"><%# Eval("created_at", "{0:dd/MM/yyyy HH:mm}") %></td>
                                <td>
                                    <asp:LinkButton ID="btnView" runat="server" CommandName="ViewOrder" CommandArgument='<%# Eval("order_id") %>' ToolTip="Xem chi tiết" style="color:#3498db; margin-right:10px; font-size:16px;">
                                        <i class="fas fa-eye"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditStatus" CommandArgument='<%# Eval("order_id") %>' ToolTip="Cập nhật trạng thái" style="color:#f39c12; margin-right:10px; font-size:16px;">
                                        <i class="fas fa-pen"></i>
                                    </asp:LinkButton>
                                    
                                    <a href="javascript:void(0)" onclick="printOrder('<%# Eval("order_id") %>')" title="In hóa đơn" style="color:#7f8c8d; font-size:16px;">
                                        <i class="fas fa-print"></i>
                                    </a>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
            
            <div style="text-align: center; padding: 30px;" id="divNoData" runat="server" visible="false">
                <p class="muted">Không tìm thấy đơn hàng nào.</p>
            </div>
        </div>
        
        <div class="pagination">
            <asp:Literal ID="litPagination" runat="server"></asp:Literal>
        </div>
    </div>

    <div id="viewModal" class="modal-backdrop" runat="server" clientidmode="Static">
        <div class="modal-content">
            <div id="invoice-area">
                <div class="invoice-header">
                    <div>
                        <h3 style="margin:0; color:#e74c3c;">BEST FOOD</h3>
                        <div class="small muted">Hóa đơn bán lẻ</div>
                    </div>
                    <div style="text-align:right;">
                        <h4 style="margin:0;">#<asp:Literal ID="litViewOrderId" runat="server"></asp:Literal></h4>
                        <div class="small muted"><asp:Literal ID="litViewDate" runat="server"></asp:Literal></div>
                    </div>
                </div>

                <div style="margin-bottom: 20px;">
                    <strong>Khách hàng:</strong> <asp:Literal ID="litViewCustomer" runat="server"></asp:Literal><br />
                    <strong>Địa chỉ:</strong> <asp:Literal ID="litViewAddress" runat="server"></asp:Literal><br />
                    <strong>Ghi chú:</strong> <em class="muted"><asp:Literal ID="litViewNote" runat="server"></asp:Literal></em>
                </div>

                <table class="invoice-table">
                    <thead>
                        <tr>
                            <th>Món ăn</th>
                            <th style="text-align:center">SL</th>
                            <th style="text-align:right">Đơn giá</th>
                            <th style="text-align:right">Thành tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptOrderItems" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><%# Eval("dish_name") %></td>
                                    <td style="text-align:center"><%# Eval("quantity") %></td>
                                    <td style="text-align:right"><%# Eval("unit_price", "{0:N0}") %></td>
                                    <td style="text-align:right"><%# Eval("total_price", "{0:N0}") %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="3" style="text-align:right; font-weight:bold; padding-top:15px;">Tổng cộng:</td>
                            <td style="text-align:right; font-weight:bold; font-size:16px; padding-top:15px; color:#e74c3c;">
                                <asp:Literal ID="litViewTotal" runat="server"></asp:Literal>
                            </td>
                        </tr>
                    </tfoot>
                </table>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn" style="background:#eee; color:#333;" onclick="closeViewModal()">Đóng</button>
                <button type="button" class="btn" style="background:#34495e; color:#fff;" onclick="window.print()"><i class="fas fa-print"></i> In ngay</button>
            </div>
        </div>
    </div>

    <div id="statusModal" class="modal-backdrop" runat="server" clientidmode="Static">
        <div class="modal-content" style="width: 400px;">
            <h3 style="margin-top:0;">Cập nhật trạng thái</h3>
            <asp:HiddenField ID="hdfEditOrderId" runat="server" ClientIDMode="Static" />
            
            <div class="form-group">
                <label>Trạng thái đơn hàng</label>
                <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-control" ClientIDMode="Static">
                    <asp:ListItem Value="PENDING">Chờ xác nhận</asp:ListItem>
                    <asp:ListItem Value="CONFIRMED">Đã xác nhận</asp:ListItem>
                    <asp:ListItem Value="PREPARING">Đang chuẩn bị</asp:ListItem>
                    <asp:ListItem Value="DELIVERING">Đang giao hàng</asp:ListItem>
                    <asp:ListItem Value="COMPLETED">Hoàn thành</asp:ListItem>
                    <asp:ListItem Value="CANCELLED">Hủy đơn</asp:ListItem>
                </asp:DropDownList>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn" style="background:#eee; color:#333;" onclick="closeStatusModal()">Hủy</button>
                <asp:Button ID="btnSaveStatus" runat="server" Text="Lưu thay đổi" CssClass="btn" style="background:#e74c3c; color:#fff;" OnClick="btnSaveStatus_Click" />
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        function showViewModal() {
            var m = document.getElementById('viewModal');
            if (m) m.style.display = 'flex';
        }
        function closeViewModal() {
            var m = document.getElementById('viewModal');
            if (m) m.style.display = 'none';
        }

        function showStatusModal() {
            var m = document.getElementById('statusModal');
            if (m) m.style.display = 'flex';
        }
        function closeStatusModal() {
            var m = document.getElementById('statusModal');
            if (m) m.style.display = 'none';
        }

        function printOrder(id) {
            // Hướng dẫn người dùng vì logic in cần load dữ liệu vào modal trước
            alert('Vui lòng bấm nút "Xem chi tiết" (icon con mắt) rồi chọn "In ngay" trong bảng hiện ra.');
        }
    </script>
</asp:Content>