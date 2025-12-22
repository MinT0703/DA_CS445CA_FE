<%@ Page Title="Thực đơn" Language="C#" MasterPageFile="~/MasterPages/Customer.Master" AutoEventWireup="true" CodeBehind="Menu.aspx.cs" Inherits="BestFoodRestaurant.Pages.Customer.Menu" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Thực đơn - BestFood
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Styles" runat="server">
    <style>
        /* CSS cho phần Menu Hero và Filter Bar */
        .menu-hero {
            max-width: 1200px;
            margin: 20px auto 10px;
            padding: 0 20px 20px;
        }
        .menu-hero h1 {
            font-size: 32px;
            color: var(--dark-color);
            margin-bottom: 6px;
        }
        .menu-hero p { color: #6b7280; }

        .filter-bar {
            position: relative;
            z-index: 10;
            background: #fff;
            border-top: 1px solid #eee;
            border-bottom: 1px solid #eee;
            box-shadow: 0 2px 8px rgba(0,0,0,.05);
            max-width: 1200px;
            margin: 0 auto;
            padding: 12px 20px;
            display: grid;
            grid-template-columns: minmax(220px,1fr) auto 200px;
            gap: 10px;
            align-items: center;
        }

        /* Search box */
        .search-wrap { display: flex; gap: 8px; }
        .search-wrap input {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #d1d5db;
            border-radius: 12px;
        }

        /* Category Pills */
        .category-pills {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            justify-content: center;
        }
        .pill-btn {
            padding: 8px 14px;
            border-radius: 999px;
            background: #f3f4f6;
            border: 1px solid #e5e7eb;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
            color: var(--text-color);
            transition: all 0.2s;
        }
        .pill-btn:hover { transform: translateY(-1px); }
        .pill-btn.active {
            background: rgba(231,76,60,.1);
            color: #b91c1c;
            border: 1px solid rgba(231,76,60,.3);
        }

        /* Grid & Card */
        .menu-grid {
            max-width: 1200px;
            margin: 18px auto 10px;
            padding: 0 20px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 18px;
        }
        .card {
            background: #fff;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 6px 18px rgba(0, 0, 0, .08);
            display: flex;
            flex-direction: column;
            transition: transform 0.25s;
        }
        .card:hover { transform: translateY(-4px); }
        .card img {
            width: 100%;
            height: 160px;
            object-fit: cover;
            background: #f3f4f6;
        }
        .card-body { padding: 14px 14px 16px; flex: 1; display: flex; flex-direction: column; }
        .card-title { font-size: 18px; color: #111827; margin: 0 0 8px; }
        .meta { display: flex; justify-content: space-between; margin-bottom: 8px; }
        .price { color: #dc2626; font-weight: 800; }
        .badge { font-size: 12px; background: #f3f4f6; padding: 3px 8px; border-radius: 999px; }
        .add-row { margin-top: auto; display: flex; gap: 10px; }
        .qty { width: 60px; padding: 8px; border-radius: 8px; border: 1px solid #ddd; }
        .btn-add {
            flex: 1; padding: 8px; background: var(--primary-color); color: #fff;
            border: none; border-radius: 8px; cursor: pointer; font-weight: 700;
        }
        .btn-add:hover { background: #c0392b; }

        @media (max-width: 900px) { .filter-bar { grid-template-columns: 1fr; } }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <section class="menu-hero">
        <h1>Thực đơn hôm nay</h1>
        <p>Chọn món bạn yêu thích từ các danh mục đa dạng của chúng tôi.</p>
    </section>

    <div class="filter-bar">
        <div class="search-wrap">
            <asp:TextBox ID="txtSearch" runat="server" placeholder="Tìm món ăn..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
        </div>

        <div class="category-pills">
            <asp:LinkButton ID="lnkAll" runat="server" CssClass="pill-btn active" OnClick="FilterCategory_Click" CommandArgument="0">Tất cả</asp:LinkButton>
            <asp:Repeater ID="rptCategories" runat="server">
                <ItemTemplate>
                    <asp:LinkButton ID="lnkCat" runat="server" CssClass="pill-btn" 
                        OnClick="FilterCategory_Click" 
                        CommandArgument='<%# Eval("category_id") %>'>
                        <%# Eval("category_name") %>
                    </asp:LinkButton>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <div class="sort-wrap">
            <asp:DropDownList ID="ddlSort" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged" CssClass="form-control" style="padding:10px; border-radius:12px; border:1px solid #ddd;">
                <asp:ListItem Value="newest">Mới nhất</asp:ListItem>
                <asp:ListItem Value="price_asc">Giá tăng dần</asp:ListItem>
                <asp:ListItem Value="price_desc">Giá giảm dần</asp:ListItem>
                <asp:ListItem Value="name_asc">Tên A-Z</asp:ListItem>
            </asp:DropDownList>
        </div>
    </div>

    <section class="menu-grid">
        <asp:Repeater ID="rptDishes" runat="server">
            <ItemTemplate>
                <article class="card">
                    <img src='<%# ResolveUrl(Eval("image_url").ToString()) %>' alt='<%# Eval("dish_name") %>' onerror="this.src='https://picsum.photos/640/360'" />
                    <div class="card-body">
                        <h3 class="card-title"><%# Eval("dish_name") %></h3>
                        <div class="meta">
                            <span class="price"><%# string.Format("{0:N0} đ", Eval("price")) %></span>
                            <span class="badge">Phần</span>
                        </div>
                        <p class="desc" style="font-size:14px; color:#666; margin-bottom:10px;">
                            <%# Eval("description") %>
                        </p>
                        
                        <div class="add-row">
                            <input class="qty" type="number" min="1" value="1" id="qty_<%# Eval("dish_id") %>">
                            <button type="button" class="btn-add" 
                                data-id='<%# Eval("dish_id") %>' 
                                data-name='<%# Eval("dish_name") %>' 
                                data-price='<%# Eval("price") %>' 
                                data-img='<%# Eval("image_url") %>'>
                                Thêm món
                            </button>
                        </div>
                    </div>
                </article>
            </ItemTemplate>
        </asp:Repeater>
        
        <asp:Label ID="lblNoData" runat="server" Text="Không tìm thấy món ăn nào." Visible="false" style="grid-column: 1/-1; text-align:center; padding: 20px; color:#666;"></asp:Label>
    </section>

</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        // Logic thêm vào giỏ hàng (LocalStorage) - Giữ nguyên từ bản HTML
        document.addEventListener('click', function (e) {
            if (e.target && e.target.classList.contains('btn-add')) {
                const btn = e.target;
                const id = btn.getAttribute('data-id');
                const name = btn.getAttribute('data-name');
                const price = parseFloat(btn.getAttribute('data-price'));
                const img = btn.getAttribute('data-img');
                
                // Lấy số lượng từ input bên cạnh nút bấm
                const qtyInput = document.getElementById('qty_' + id);
                const qty = parseInt(qtyInput ? qtyInput.value : 1) || 1;

                addToCart({ id, name, price, qty, image: img });
                
                // Hiệu ứng báo thành công đơn giản
                const originalText = btn.textContent;
                btn.textContent = "Đã thêm!";
                btn.style.background = "#27ae60";
                setTimeout(() => {
                    btn.textContent = originalText;
                    btn.style.background = "";
                }, 1000);
            }
        });

        function addToCart(item) {
            const key = 'bestfood_cart';
            let cart = [];
            try { cart = JSON.parse(localStorage.getItem(key) || '[]'); } catch { }

            const idx = cart.findIndex(i => String(i.id) === String(item.id));
            if (idx >= 0) {
                cart[idx].qty = Number(cart[idx].qty || 0) + Number(item.qty);
            } else {
                cart.push(item);
            }

            localStorage.setItem(key, JSON.stringify(cart));
            // Trigger event để update badge giỏ hàng nếu có
            window.dispatchEvent(new StorageEvent('storage', { key: key, newValue: JSON.stringify(cart) }));
        }
    </script>
</asp:Content>