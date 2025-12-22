<%@ Page Title="Thanh toán" Language="C#" MasterPageFile="~/MasterPages/Customer.Master" AutoEventWireup="true" CodeBehind="Pay.aspx.cs" Inherits="BestFoodRestaurant.Pages.Customer.Pay" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Thanh toán - BestFood
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Styles" runat="server">
    <style>
        .checkout-grid { display: grid; grid-template-columns: 1.2fr .8fr; gap: 18px; max-width: 1200px; margin: 22px auto; padding: 0 20px; }
        @media(max-width:900px) { .checkout-grid { grid-template-columns: 1fr; } }
        
        .card-panel { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        
        .form-group { margin-bottom: 15px; }
        .form-control { width: 100%; padding: 12px; border-radius: 8px; border: 1px solid #ddd; font-size: 14px; }
        .form-control:focus { border-color: #e74c3c; outline: none; }
        
        .payment-method { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 15px; border: 1px solid #eee; border-radius: 10px; cursor: pointer; background: #fff; margin-bottom: 10px; transition: all 0.2s; }
        .payment-method:hover { border-color: #e74c3c; background: #fffbfb; }
        .payment-method.active { border-color: #e74c3c; background: #fff5f5; box-shadow: 0 0 0 1px #e74c3c inset; }
        
        .payment-method input[type="radio"] { margin-right: 12px; accent-color: #e74c3c; transform: scale(1.2); }
        
        .order-summary-item { display: flex; gap: 12px; align-items: center; padding: 10px 0; border-bottom: 1px solid #f9f9f9; }
        .order-summary-item img { width: 60px; height: 60px; object-fit: cover; border-radius: 8px; border: 1px solid #eee; }
        
        .btn-pay { background: linear-gradient(90deg, #e74c3c 0%, #c0392b 100%); color: white; width: 100%; padding: 16px; border: none; border-radius: 8px; font-weight: bold; font-size: 16px; cursor: pointer; text-transform: uppercase; letter-spacing: 0.5px; transition: all 0.2s; }
        .btn-pay:hover { transform: translateY(-2px); box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3); }

        .error-msg { color: #e74c3c; font-size: 13px; margin-top: 5px; display: block; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <main class="checkout-grid">
        <section class="card-panel">
            <h2 style="margin-top:0; color:#333;">Thanh toán & Đặt món</h2>
            <p class="muted" style="margin-bottom:20px; color:#666;">Vui lòng điền thông tin giao hàng.</p>
            
            <h3 style="font-size:18px; margin-bottom:15px; border-bottom:1px solid #eee; padding-bottom:10px;">Thông tin giao hàng</h3>
            <div class="form-group">
                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Họ và tên người nhận"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Vui lòng nhập họ tên" CssClass="error-msg" Display="Dynamic" ValidationGroup="Checkout"></asp:RequiredFieldValidator>
            </div>
            
            <div class="form-group">
                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="Số điện thoại"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="Vui lòng nhập số điện thoại" CssClass="error-msg" Display="Dynamic" ValidationGroup="Checkout"></asp:RequiredFieldValidator>
            </div>

            <div class="form-group">
                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" placeholder="Địa chỉ giao hàng (Số nhà, đường, quận...)"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvAddress" runat="server" ControlToValidate="txtAddress" ErrorMessage="Vui lòng nhập địa chỉ" CssClass="error-msg" Display="Dynamic" ValidationGroup="Checkout"></asp:RequiredFieldValidator>
            </div>

            <div class="form-group">
                <asp:TextBox ID="txtNote" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Ghi chú cho nhà bếp (Ví dụ: Ít cay, không hành...)"></asp:TextBox>
            </div>

            <h3 style="font-size:18px; margin: 25px 0 15px; border-bottom:1px solid #eee; padding-bottom:10px;">Phương thức thanh toán</h3>
            <div id="paymentOptions">
                <label class="payment-method active">
                    <div style="display:flex;align-items:center;">
                        <input type="radio" name="payment" value="COD" checked="checked" onclick="selectPayment('COD')" />
                        <div>
                            <div style="font-weight:700; color:#333;">Thanh toán khi nhận hàng (COD)</div>
                            <div style="font-size:13px;color:#777">Thanh toán tiền mặt cho shipper</div>
                        </div>
                    </div>
                    <i class="fas fa-money-bill-wave" style="font-size:24px;color:#27ae60"></i>
                </label>

                <label class="payment-method">
                    <div style="display:flex;align-items:center;">
                        <input type="radio" name="payment" value="BANK" onclick="selectPayment('BANK')" />
                        <div>
                            <div style="font-weight:700; color:#333;">Chuyển khoản ngân hàng</div>
                            <div style="font-size:13px;color:#777">Vietcombank - BestFood JSC</div>
                        </div>
                    </div>
                    <i class="fas fa-university" style="font-size:24px;color:#2980b9"></i>
                </label>
            </div>

            <asp:HiddenField ID="hfPaymentMethod" runat="server" Value="COD" />
            <asp:HiddenField ID="hfCartJson" runat="server" />
            <asp:HiddenField ID="hfTotalAmount" runat="server" />

            <div style="margin-top: 25px;">
                <asp:Button ID="btnPlaceOrder" runat="server" Text="Xác nhận đặt hàng" CssClass="btn-pay" OnClick="btnPlaceOrder_Click" ValidationGroup="Checkout" OnClientClick="return prepareOrder();" />
            </div>
        </section>

        <aside class="card-panel">
            <h3 style="margin-top:0; margin-bottom:15px; border-bottom:1px solid #eee; padding-bottom:10px;">Đơn hàng của bạn</h3>
            <div id="orderItemsList" style="margin-top: 12px; max-height: 400px; overflow-y: auto;">
                <div style="text-align:center; padding: 20px; color:#999;"><i class="fas fa-spinner fa-spin"></i> Đang tải...</div>
            </div>

            <hr style="margin: 20px 0; border: 0; border-top: 1px dashed #eee;" />
            
            <div style="display:flex;justify-content:space-between;margin-bottom:10px;font-size:14px;">
                <div style="color:#666;">Tạm tính</div>
                <div id="lblSubTotal" style="font-weight:600;">0 đ</div>
            </div>
            <div style="display:flex;justify-content:space-between;margin-bottom:10px;font-size:14px;">
                <div style="color:#666;">Phí vận chuyển</div>
                <div id="lblShip" style="font-weight:600;">0 đ</div>
            </div>
            <div style="display:flex;justify-content:space-between;margin-bottom:10px;font-size:14px; color: #27ae60;">
                <div>Giảm giá</div>
                <div id="lblDiscount" style="font-weight:600;">0 đ</div>
            </div>
            <hr style="margin: 15px 0; border: 0; border-top: 1px solid #eee;" />
            <div style="display:flex;justify-content:space-between;align-items:center;">
                <div style="font-weight:bold; font-size:16px;">Tổng cộng</div>
                <div id="lblGrandTotal" style="font-weight:bold; font-size:22px; color:#e74c3c;">0 đ</div>
            </div>
        </aside>
    </main>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        const STORAGE_KEY = 'bestfood_cart';

        // Load cart on init
        document.addEventListener('DOMContentLoaded', () => {
            renderOrderSummary();
            fillUserInfo();
        });

        function formatMoney(n) {
            return (Number(n) || 0).toLocaleString('vi-VN') + ' đ';
        }

        function renderOrderSummary() {
            try {
                const cart = JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]');
                const container = document.getElementById('orderItemsList');

                if (cart.length === 0) {
                    container.innerHTML = '<div style="color:#e74c3c; text-align:center; padding:20px;">Giỏ hàng trống!</div>';
                    // Disable nút đặt hàng nếu giỏ trống
                    const btn = document.getElementById('<%= btnPlaceOrder.ClientID %>');
                    if (btn) btn.disabled = true;
                    return;
                }

                // Render HTML
                let html = '';
                let subTotal = 0;
                cart.forEach(item => {
                    let total = (item.price || 0) * (item.qty || 1);
                    subTotal += total;
                    html += `
                        <div class="order-summary-item">
                            <img src="${item.image || 'https://picsum.photos/60'}" onerror="this.src='https://picsum.photos/60'" />
                            <div style="flex:1">
                                <div style="font-weight:600;font-size:14px;color:#333;">${item.name}</div>
                                <div style="font-size:12px;color:#888;">Số lượng: ${item.qty}</div>
                            </div>
                            <div style="font-weight:bold;font-size:14px;color:#333;">${formatMoney(total)}</div>
                        </div>
                    `;
                });
                container.innerHTML = html;

                // Calc totals
                let ship = subTotal >= 500000 ? 0 : 20000;
                let discount = Number(localStorage.getItem('bestfood_coupon_discount') || 0);
                let grand = Math.max(0, subTotal + ship - discount);

                // Update UI
                document.getElementById('lblSubTotal').textContent = formatMoney(subTotal);
                document.getElementById('lblShip').textContent = formatMoney(ship);
                document.getElementById('lblDiscount').textContent = '-' + formatMoney(discount);
                document.getElementById('lblGrandTotal').textContent = formatMoney(grand);

                // Update HiddenField for Server
                document.getElementById('<%= hfTotalAmount.ClientID %>').value = grand;

            } catch (e) {
                console.error(e);
            }
        }

        function selectPayment(method) {
            document.getElementById('<%= hfPaymentMethod.ClientID %>').value = method;

            // UI Toggle
            const options = document.querySelectorAll('.payment-method');
            options.forEach(opt => opt.classList.remove('active'));
            event.currentTarget.closest('.payment-method').classList.add('active');
        }

        // Chạy trước khi postback để gom dữ liệu
        function prepareOrder() {
            const cart = localStorage.getItem(STORAGE_KEY) || '[]';
            if (cart === '[]') {
                alert('Giỏ hàng trống, không thể đặt hàng!');
                return false;
            }
            document.getElementById('<%= hfCartJson.ClientID %>').value = cart;
            return true;
        }

        // Tự động điền nếu có thông tin user trong localStorage
        function fillUserInfo() {
            try {
                const user = JSON.parse(localStorage.getItem('currentUser') || '{}');
                if (user.name) {
                    const elName = document.getElementById('<%= txtFullName.ClientID %>');
                    if(elName && !elName.value) elName.value = user.name;
                }
                if (user.phone) {
                    const elPhone = document.getElementById('<%= txtPhone.ClientID %>');
                    if(elPhone && !elPhone.value) elPhone.value = user.phone;
                }
                if (user.address) {
                    const elAddr = document.getElementById('<%= txtAddress.ClientID %>');
                    if (elAddr && !elAddr.value) elAddr.value = user.address;
                }
            } catch { }
        }
    </script>
</asp:Content>