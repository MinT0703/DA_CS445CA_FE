<%@ Page Title="Giỏ hàng" Language="C#" MasterPageFile="~/MasterPages/Customer.Master" AutoEventWireup="true" CodeBehind="Cart.aspx.cs" Inherits="BestFoodRestaurant.Pages.Customer.Cart" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Giỏ hàng - BestFood
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Styles" runat="server">
    <style>
        .cart-hero {
            background: linear-gradient( rgba(0,0,0,.25), rgba(0,0,0,.25) ),
                        url("https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=1400&q=80") center/cover no-repeat;
            color: #fff;
            padding: 56px 0;
            text-align: center;
        }
        .cart-wrap { max-width:1200px; margin: 22px auto; padding: 0 20px; }
        .cart-grid {
            display: grid;
            grid-template-columns: 1fr 360px;
            gap: 18px;
        }
        @media (max-width: 900px) { .cart-grid { grid-template-columns: 1fr; } }

        .cart-list { display:flex; flex-direction:column; gap:12px; }
        .cart-item {
            display:flex; gap:12px; align-items:center;
            padding:12px; border-radius:12px; background:#fff;
            border:1px solid #f3f4f6;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05); /* Thêm bóng đổ nhẹ */
        }
        .cart-item img { width:92px; height:72px; object-fit:cover; border-radius:8px; }
        .ci-body { flex:1; display:flex; flex-direction:column; gap:6px; }
        .ci-title { font-weight:700; color:var(--dark-color); font-size: 16px; }
        .ci-meta { display:flex; gap:10px; align-items:center; color:var(--muted); font-size:13px; }
        .ci-actions { display:flex; gap:8px; align-items:center; margin-top: 4px; }

        .qty-control { display:flex; align-items:center; gap:5px; }
        .qty-control button {
            width:32px; height:32px; border-radius:6px; border:1px solid #ddd; background:#fff; cursor:pointer; color: #333; font-weight: bold;
        }
        .qty-control button:hover { background: #f9f9f9; }
        .qty-control input { width:50px; text-align:center; padding:6px; border-radius:6px; border:1px solid #ddd; font-weight: 600; }

        .summary { background:#fff; padding:20px; border-radius:12px; border:1px solid #f3f4f6; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .summary h3 { margin:0 0 16px; font-size: 18px; border-bottom: 1px solid #eee; padding-bottom: 10px; }
        .row-summary { display:flex; justify-content:space-between; align-items:center; margin:10px 0; }
        .total { font-weight:900; font-size:20px; color:var(--primary-color); }
        .muted-small { font-size:14px; color:#666; }

        .empty-cart { text-align:center; padding:40px; background:#fff; border-radius:12px; border:1px dashed #ddd; color:#888; }
        .cart-actions { display:flex; gap:10px; margin-top:10px; }
        
        /* Button Styles Fix */
        .btn-checkout { 
            background: #e74c3c; /* Màu đỏ chủ đạo */
            background: linear-gradient(90deg, #e74c3c 0%, #c0392b 100%); 
            width: 100%; 
            color: white; 
            border: none; 
            padding: 14px; 
            border-radius: 8px; 
            cursor: pointer; 
            font-weight: bold;
            font-size: 16px;
            transition: all 0.2s;
        }
        .btn-checkout:hover { transform: translateY(-1px); box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3); }

        .btn-sm { padding: 8px 12px; border-radius: 8px; border: 1px solid #ddd; background: #fff; cursor: pointer; color: #333; font-size: 13px; font-weight: 600; }
        .btn-sm:hover { background: #f5f5f5; }

        /* Nút Áp dụng mã giảm giá */
        .btn-apply {
            background: #2c3e50; /* Màu tối */
            color: white;
            border: none;
        }
        .btn-apply:hover { background: #1a252f; }

        /* Nút Xóa item (Thùng rác) */
        .btn-remove {
            color: #e74c3c;
            border-color: #fadbd8;
            background: #fff;
            width: 36px; 
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            font-size: 16px;
            transition: all 0.2s;
        }
        .btn-remove:hover {
            background: #fdecea;
            border-color: #e74c3c;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <section class="cart-hero">
        <div class="container">
            <h1>Giỏ hàng của bạn</h1>
            <p class="muted">Kiểm tra, cập nhật số lượng và tiến hành thanh toán.</p>
        </div>
    </section>

    <main class="cart-wrap">
        <div class="cart-grid">
            <section>
                <div id="listArea">
                    <div class="empty-cart"><i class="fas fa-spinner fa-spin"></i> Đang tải giỏ hàng...</div>
                </div>
            </section>

            <aside>
                <div class="summary">
                    <h3>Tóm tắt đơn hàng</h3>
                    <div class="row-summary"><div class="muted-small">Tạm tính</div><div id="subTotal">0 đ</div></div>
                    <div class="row-summary"><div class="muted-small">Phí giao hàng</div><div id="shipFee">0 đ</div></div>
                    <div class="row-summary"><div class="muted-small">Giảm giá</div><div id="discount">0 đ</div></div>
                    <hr style="margin: 15px 0; border: 0; border-top: 1px solid #eee;" />
                    <div class="row-summary total"><div>Tổng</div><div id="grandTotal">0 đ</div></div>

                    <div style="margin-top:20px">
                        <input id="coupon" placeholder="Mã giảm giá (nếu có)" style="width:100%; padding:12px; border-radius:8px; border:1px solid #ddd; margin-bottom: 10px;" />
                        <div class="cart-actions">
                            <button id="applyCoupon" type="button" class="btn-sm btn-apply" style="flex:1;">Áp dụng</button>
                            <button id="clearCart" type="button" class="btn-sm" style="background:#f3f4f6;color:#333; flex:1;">Xoá giỏ</button>
                        </div>
                        <div style="margin-top:15px">
                            <button id="checkout" type="button" class="btn-checkout">Thanh toán</button>
                        </div>
                    </div>
                </div>
            </aside>
        </div>
    </main>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        const STORAGE_KEY = 'bestfood_cart';

        function currency(v) { return (Number(v) || 0).toLocaleString('vi-VN') + ' đ'; }

        function loadCart() {
            try { return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]'); }
            catch { return []; }
        }
        function saveCart(cart) { localStorage.setItem(STORAGE_KEY, JSON.stringify(cart)); }

        function calcTotals(cart) {
            const sub = cart.reduce((s, it) => s + (Number(it.price) || 0) * (Number(it.qty) || 0), 0);
            const ship = sub >= 500000 ? 0 : (sub === 0 ? 0 : 20000);
            const discount = Number(localStorage.getItem('bestfood_coupon_discount') || 0);
            const grand = Math.max(0, sub + ship - discount);
            return { sub, ship, discount, grand };
        }

        function renderEmpty() {
            const listArea = document.getElementById('listArea');
            if (listArea) {
                listArea.innerHTML = `
                    <div class="empty-cart">
                      <i class="fas fa-shopping-basket" style="font-size: 48px; color: #ddd; margin-bottom: 15px;"></i>
                      <p>Giỏ hàng của bạn đang trống.</p>
                      <p style="margin-top:15px"><a href="Menu.aspx" class="btn" style="background:#e74c3c; color:white; padding:10px 24px; border-radius:30px; text-decoration:none; font-weight:600;">Xem Thực đơn</a></p>
                    </div>`;
            }
            updateSummary([]);
        }

        function renderCart() {
            const cart = loadCart();
            if (!cart.length) { renderEmpty(); return; }

            const escapeHtml = (s) => (s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

            // Sửa: Thay nút Xóa text bằng Icon thùng rác và thêm class btn-remove
            const html = cart.map(it => `
                <div class="cart-item" data-id="${encodeURIComponent(it.id)}">
                  <img src="${it.image || 'https://picsum.photos/320/240'}" alt="${escapeHtml(it.name)}" onerror="this.src='https://picsum.photos/320/240'" />
                  <div class="ci-body">
                    <div class="ci-title">${escapeHtml(it.name)}</div>
                    <div class="ci-meta"><span class="muted-small">${it.unit || 'Phần'}</span> <span class="muted-small">| Đơn giá: <b>${currency(it.price)}</b></span></div>
                    <div class="ci-actions">
                      <div class="qty-control">
                        <button class="qty-dec" title="Giảm" type="button"><i class="fas fa-minus" style="font-size:10px"></i></button>
                        <input class="qty-input" type="number" min="1" value="${it.qty || 1}" />
                        <button class="qty-inc" title="Tăng" type="button"><i class="fas fa-plus" style="font-size:10px"></i></button>
                      </div>
                      <div style="margin-left:auto;font-weight:800;color:#e74c3c">${currency((Number(it.price) || 0) * (Number(it.qty) || 1))}</div>
                      
                      <button class="btn-sm remove-item btn-remove" style="margin-left:12px" type="button" title="Xóa món này">
                        <i class="fas fa-trash-alt"></i>
                      </button>

                    </div>
                  </div>
                </div>
            `).join('');

            const listArea = document.getElementById('listArea');
            if (listArea) listArea.innerHTML = `<div class="cart-list">${html}</div>`;

            attachItemHandlers();
            updateSummary(cart);
        }

        function updateSummary(cart) {
            const t = calcTotals(cart || []);
            const elSub = document.getElementById('subTotal');
            const elShip = document.getElementById('shipFee');
            const elDisc = document.getElementById('discount');
            const elGrand = document.getElementById('grandTotal');

            if (elSub) elSub.textContent = currency(t.sub);
            if (elShip) elShip.textContent = currency(t.ship);
            if (elDisc) elDisc.textContent = currency(t.discount);
            if (elGrand) elGrand.textContent = currency(t.grand);
        }

        function attachItemHandlers() {
            const list = document.querySelectorAll('.cart-item');
            list.forEach(node => {
                const id = decodeURIComponent(node.dataset.id);
                const dec = node.querySelector('.qty-dec');
                const inc = node.querySelector('.qty-inc');
                const inp = node.querySelector('.qty-input');
                const rem = node.querySelector('.remove-item');

                // Dùng closet để tránh lỗi click vào icon bên trong nút
                dec.addEventListener('click', () => changeQty(id, Math.max(1, Number(inp.value || 1) - 1)));
                inc.addEventListener('click', () => changeQty(id, Number(inp.value || 1) + 1));
                inp.addEventListener('change', () => changeQty(id, Math.max(1, Number(inp.value || 1))));
                rem.addEventListener('click', () => removeItem(id));
            });
        }

        function changeQty(id, newQty) {
            const cart = loadCart();
            const idx = cart.findIndex(i => String(i.id) === String(id));
            if (idx === -1) return;
            cart[idx].qty = Number(newQty) || 1;
            saveCart(cart);
            renderCart();
        }

        function removeItem(id) {
            if (!confirm('Bạn có chắc muốn xóa món này khỏi giỏ hàng?')) return;
            let cart = loadCart();
            cart = cart.filter(i => String(i.id) !== String(id));
            saveCart(cart);
            renderCart();
        }

        document.addEventListener('DOMContentLoaded', () => {
            renderCart();

            const btnClear = document.getElementById('clearCart');
            if (btnClear) {
                btnClear.addEventListener('click', () => {
                    if (!confirm('Xoá toàn bộ giỏ hàng?')) return;
                    localStorage.removeItem(STORAGE_KEY);
                    localStorage.removeItem('bestfood_coupon_discount');
                    renderCart();
                });
            }

            const btnApply = document.getElementById('applyCoupon');
            if (btnApply) {
                btnApply.addEventListener('click', () => {
                    const couponInput = document.getElementById('coupon');
                    const code = (couponInput.value || '').trim().toUpperCase();
                    let discount = 0;
                    const cart = loadCart();
                    const sub = calcTotals(cart).sub;

                    if (!code) { alert('Nhập mã giảm giá'); return; }

                    if (code === 'PROMO20') { discount = 20000; }
                    else if (code === 'FIRST10' && sub >= 200000) { discount = Math.round(sub * 0.10); }
                    else { alert('Mã giảm giá không hợp lệ hoặc điều kiện chưa đạt!'); return; }

                    localStorage.setItem('bestfood_coupon_discount', String(discount));
                    updateSummary(cart);
                    alert('Áp dụng mã giảm giá thành công! Bạn được giảm ' + currency(discount));
                });
            }

            const btnCheckout = document.getElementById('checkout');
            if (btnCheckout) {
                btnCheckout.addEventListener('click', () => {
                    const cart = loadCart();
                    if (!cart.length) { alert('Giỏ hàng trống'); return; }

                    localStorage.setItem('bestfood_last_order', JSON.stringify({
                        items: cart,
                        totals: calcTotals(cart),
                        created_at: new Date().toISOString()
                    }));

                    window.location.href = 'Pay.aspx';
                });
            }
        });

        window.addEventListener('storage', (e) => {
            if (e.key === STORAGE_KEY || e.key === 'bestfood_coupon_discount') renderCart();
        });
    </script>
</asp:Content>