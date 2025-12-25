<%@ Page Title="Quản lý Món ăn" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Menu.aspx.cs" Inherits="BestFoodRestaurant.Pages.Admin.Menu" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .table-wrap { overflow-x: auto; padding-bottom: 20px; }
        .admin-table { width: 100%; border-collapse: collapse; min-width: 900px; }
        .admin-table th, .admin-table td { padding: 12px 15px; border-bottom: 1px solid #eee; text-align: left; vertical-align: middle; }
        .admin-table th { background: #f8f9fa; color: #666; font-weight: 600; font-size: 13px; text-transform: uppercase; }
        
        .dish-thumb { width: 60px; height: 48px; border-radius: 6px; object-fit: cover; margin-right: 10px; border: 1px solid #eee; display: inline-block; vertical-align: middle; }
        
        .status-active { color: #2ecc71; font-weight: 600; background: rgba(46, 204, 113, 0.1); padding: 4px 8px; border-radius: 4px; }
        .status-inactive { color: #95a5a6; font-weight: 600; background: rgba(149, 165, 166, 0.1); padding: 4px 8px; border-radius: 4px; }

        /* Modal Styles */
        .modal-backdrop { 
            position: fixed; top: 0; left: 0; right: 0; bottom: 0; 
            background: rgba(0,0,0,0.5); z-index: 999; 
            display: none; align-items: center; justify-content: center; 
        }
        .modal-content { 
            background: #fff; width: 600px; max-width: 95%; 
            padding: 25px; border-radius: 12px; box-shadow: 0 5px 20px rgba(0,0,0,0.2); 
            max-height: 90vh; overflow-y: auto;
        }
        .form-row { display: flex; gap: 15px; }
        .form-group { margin-bottom: 15px; flex: 1; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 600; font-size: 13px; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; }
        
        .img-preview-box {
            width: 100px; height: 100px; border: 2px dashed #ddd; border-radius: 8px;
            display: flex; align-items: center; justify-content: center; overflow: hidden;
            margin-top: 5px; background: #fafafa;
        }
        .img-preview-box img { max-width: 100%; max-height: 100%; object-fit: cover; }

        .modal-footer { margin-top: 20px; text-align: right; display: flex; gap: 10px; justify-content: flex-end; }
        .pagination { display: flex; gap: 5px; justify-content: flex-end; margin-top: 20px; }
        .page-item { padding: 6px 12px; border: 1px solid #ddd; border-radius: 4px; color: #333; text-decoration: none; }
        .page-item.active { background: #e74c3c; color: #fff; border-color: #e74c3c; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="card-panel" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
        <div>
            <h2 style="margin: 0;">Quản lý Món ăn</h2>
            <p class="muted small" style="margin: 5px 0 0;">Thêm, sửa, xóa và cập nhật thực đơn nhà hàng.</p>
        </div>
        <div style="display: flex; gap: 10px;">
            <asp:Button ID="btnExport" runat="server" Text="Xuất CSV" CssClass="btn" style="background:#27ae60; color:#fff;" OnClick="btnExport_Click" />
            <button type="button" class="btn" style="background:var(--primary-color); color:#fff;" onclick="openAddModal()">+ Thêm món</button>
        </div>
    </div>

    <div class="card-panel">
        <div style="display: flex; gap: 10px; margin-bottom: 20px; flex-wrap: wrap;">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" Placeholder="Tìm tên món..." style="width: 200px; display:inline-block;"></asp:TextBox>
            
            <asp:DropDownList ID="ddlCategoryFilter" runat="server" CssClass="form-control" style="width: 180px; display:inline-block;">
                <asp:ListItem Value="">-- Tất cả danh mục --</asp:ListItem>
            </asp:DropDownList>

            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-control" style="width: 150px; display:inline-block;">
                <asp:ListItem Value="">-- Trạng thái --</asp:ListItem>
                <asp:ListItem Value="1">Đang bán</asp:ListItem>
                <asp:ListItem Value="0">Ngừng bán</asp:ListItem>
            </asp:DropDownList>

            <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn" style="background:#34495e; color:#fff;" OnClick="btnSearch_Click" />
        </div>

        <div class="table-wrap">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Món ăn</th>
                        <th>Danh mục</th>
                        <th>Giá bán</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptDishes" runat="server" OnItemCommand="rptDishes_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td>#<%# Eval("dish_id") %></td>
                                <td>
                                    <img src='<%# ResolveUrl(Eval("image_url").ToString()) %>' class="dish-thumb" onerror="this.src='/Assets/images/no-food.png'" />
                                    <span style="font-weight: 600;"><%# Eval("dish_name") %></span>
                                </td>
                                <td><%# Eval("category_name") %></td>
                                <td style="font-weight: bold; color: #e74c3c;"><%# Eval("price", "{0:N0} đ") %></td>
                                <td>
                                    <span class='<%# Convert.ToBoolean(Eval("is_available")) ? "status-active" : "status-inactive" %>'>
                                        <%# Convert.ToBoolean(Eval("is_available")) ? "Đang bán" : "Ngừng bán" %>
                                    </span>
                                </td>
                                <td>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditDish" CommandArgument='<%# Eval("dish_id") %>' ToolTip="Sửa" style="color:#f39c12; margin-right:8px; font-size:16px;">
                                        <i class="fas fa-pen"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnToggle" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("dish_id") %>' ToolTip="Bật/Tắt" style="color:#95a5a6; margin-right:8px; font-size:16px;">
                                        <i class="fas fa-power-off"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteDish" CommandArgument='<%# Eval("dish_id") %>' ToolTip="Xóa" style="color:#e74c3c; font-size:16px;" OnClientClick="return confirm('Bạn có chắc chắn muốn xóa món này?');">
                                        <i class="fas fa-trash"></i>
                                    </asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
            
            <div style="text-align: center; padding: 30px;" id="divNoData" runat="server" visible="false">
                <p class="muted">Không tìm thấy món ăn nào.</p>
            </div>
        </div>
        
        <div class="pagination">
            <asp:Literal ID="litPagination" runat="server"></asp:Literal>
        </div>
    </div>

    <div id="menuModal" class="modal-backdrop" runat="server" clientidmode="Static">
        <div class="modal-content">
            <h3 id="modalTitle" style="margin-top:0;">Thêm món mới</h3>
            
            <asp:HiddenField ID="hdfDishId" runat="server" ClientIDMode="Static" />
            <asp:HiddenField ID="hdfOldImage" runat="server" ClientIDMode="Static" />
            
            <div class="form-row">
                <div class="form-group">
                    <label>Tên món ăn <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtName" runat="server" CssClass="form-control" ClientIDMode="Static"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Danh mục <span style="color:red">*</span></label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control" ClientIDMode="Static"></asp:DropDownList>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Giá bán (VNĐ) <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtPrice" runat="server" CssClass="form-control" TextMode="Number" ClientIDMode="Static"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Trạng thái</label>
                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control" ClientIDMode="Static">
                        <asp:ListItem Value="1">Đang bán</asp:ListItem>
                        <asp:ListItem Value="0">Ngừng bán</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <div class="form-group">
                <label>Mô tả chi tiết</label>
                <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" ClientIDMode="Static"></asp:TextBox>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Hình ảnh</label>
                    <asp:FileUpload ID="fileImage" runat="server" CssClass="form-control" onchange="previewImage(this)" />
                    <div style="font-size:11px; color:#999; margin-top:3px;">Để trống nếu không muốn đổi ảnh (khi sửa).</div>
                </div>
                <div class="img-preview-box">
                    <img id="imgPreview" src="/Assets/images/no-food.png" alt="Preview" />
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn" style="background:#eee; color:#333;" onclick="closeModal()">Hủy</button>
                <asp:Button ID="btnSave" runat="server" Text="Lưu món ăn" CssClass="btn" style="background:#e74c3c; color:#fff;" OnClick="btnSave_Click" />
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        function openAddModal() {
            var modal = document.getElementById('menuModal');
            if (modal) {
                modal.style.display = 'flex';
                document.getElementById('modalTitle').innerText = 'Thêm món mới';
                
                // Reset form
                if(document.getElementById('hdfDishId')) document.getElementById('hdfDishId').value = '';
                if(document.getElementById('txtName')) document.getElementById('txtName').value = '';
                if(document.getElementById('txtPrice')) document.getElementById('txtPrice').value = '';
                if(document.getElementById('txtDescription')) document.getElementById('txtDescription').value = '';
                if(document.getElementById('ddlStatus')) document.getElementById('ddlStatus').value = '1';
                document.getElementById('imgPreview').src = '/Assets/images/no-food.png';
            }
        }

        function showEditModal() {
            var modal = document.getElementById('menuModal');
            if (modal) {
                modal.style.display = 'flex';
                document.getElementById('modalTitle').innerText = 'Cập nhật món ăn';
                
                // Load ảnh cũ lên preview (nếu có)
                var oldImg = document.getElementById('hdfOldImage').value;
                if(oldImg) document.getElementById('imgPreview').src = oldImg;
            }
        }

        function closeModal() {
            var modal = document.getElementById('menuModal');
            if(modal) modal.style.display = 'none';
        }

        // Script xem trước ảnh khi chọn file
        function previewImage(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    document.getElementById('imgPreview').src = e.target.result;
                }
                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>
</asp:Content>