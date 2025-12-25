<%@ Page Title="Dashboard Admin" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="BestFoodRestaurant.Pages.Admin.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

    <style>
        /* CSS riêng cho Dashboard */
        .admin-main { display: flex; flex-direction: column; gap: 18px; }
        .kpi-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 18px; }
        .kpi { text-align: center; border-radius: 10px; padding: 20px; transition: transform 0.2s; }
        .kpi:hover { transform: translateY(-3px); }
        .kpi .num { font-size: 24px; font-weight: 800; color: #e74c3c; margin-top: 10px; }
        .kpi .label { color: #7f8c8d; font-size: 13px; font-weight: 600; text-transform: uppercase; }

        .dashboard-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 18px; }
        
        .top-dishes-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .top-dishes-table th, .top-dishes-table td { text-align: left; padding: 12px; border-bottom: 1px solid #f1f1f1; font-size: 14px; }
        .top-dishes-table th { color: #95a5a6; font-size: 12px; text-transform: uppercase; }

        @media (max-width: 900px) {
            .kpi-row { grid-template-columns: 1fr; }
            .dashboard-grid { grid-template-columns: 1fr; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="card-panel">
        <h2 style="margin: 0 0 6px">Dashboard Tổng quan</h2>
        <p class="muted" style="margin: 0">Chào mừng quay trở lại! Dưới đây là tình hình kinh doanh trong 30 ngày qua.</p>
    </div>

    <div class="kpi-row">
        <div class="card-panel kpi">
            <div class="label">Doanh thu (30 ngày)</div>
            <div class="num">
                <asp:Literal ID="litRevenue" runat="server">0 đ</asp:Literal>
            </div>
        </div>
        <div class="card-panel kpi">
            <div class="label">Tổng đơn hàng</div>
            <div class="num">
                <asp:Literal ID="litOrders" runat="server">0</asp:Literal>
            </div>
        </div>
        <div class="card-panel kpi">
            <div class="label">Món bán chạy nhất</div>
            <div class="num" style="font-size: 18px; color: #2ecc71;">
                <asp:Literal ID="litTopDish" runat="server">---</asp:Literal>
            </div>
        </div>
    </div>

    <div class="dashboard-grid">
        
        <div class="card-panel">
            <h3 style="margin-top: 0; margin-bottom: 20px;">Biểu đồ doanh thu (7 ngày gần nhất)</h3>
            <div style="height: 300px; width: 100%;">
                <canvas id="revenueChart"></canvas>
            </div>
        </div>

        <div class="card-panel">
            <h3 style="margin-top: 0;">Top món ăn hot</h3>
            <table class="top-dishes-table">
                <thead>
                    <tr>
                        <th>Món ăn</th>
                        <th style="text-align:center">SL Bán</th>
                        <th style="text-align:right">Doanh thu</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptTopDishes" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight: 600; color: #34495e;"><%# Eval("DishName") %></td>
                                <td style="text-align:center"><span style="background:#eee; padding: 2px 8px; border-radius:10px; font-size:12px"><%# Eval("Quantity") %></span></td>
                                <td style="text-align:right; color:#e74c3c; font-weight:bold"><%# Eval("Revenue", "{0:N0} đ") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:PlaceHolder ID="phNoData" runat="server" Visible="false">
                        <tr>
                            <td colspan="3" style="text-align:center; color:#999; padding: 20px;">Chưa có dữ liệu bán hàng.</td>
                        </tr>
                    </asp:PlaceHolder>
                </tbody>
            </table>
        </div>
    </div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            // Lấy dữ liệu từ Code Behind (đã được inject vào biến toàn cục)
            // chartData được định nghĩa ở file .cs bằng ClientScript
            const dataFromServer = window.chartData || { labels: [], data: [] };

            const ctx = document.getElementById('revenueChart').getContext('2d');
            
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: dataFromServer.labels,
                    datasets: [{
                        label: 'Doanh thu',
                        data: dataFromServer.data,
                        fill: true,
                        tension: 0.4, // Đường cong mềm mại
                        borderWidth: 2,
                        pointRadius: 4,
                        backgroundColor: (ctx) => {
                            const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300);
                            g.addColorStop(0, 'rgba(231,76,60,0.2)');
                            g.addColorStop(1, 'rgba(231,76,60,0.0)');
                            return g;
                        },
                        borderColor: '#e74c3c',
                        pointBackgroundColor: '#fff',
                        pointBorderColor: '#e74c3c'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    let label = context.dataset.label || '';
                                    if (label) { label += ': '; }
                                    if (context.parsed.y !== null) {
                                        label += new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(context.parsed.y);
                                    }
                                    return label;
                                }
                            }
                        }
                    },
                    scales: {
                        x: { grid: { display: false } },
                        y: {
                            beginAtZero: true,
                            grid: { color: '#f5f5f5' },
                            ticks: {
                                callback: function(value) {
                                    // Rút gọn số tiền (ví dụ 1.000.000 -> 1M) cho gọn
                                    if(value >= 1000000) return (value/1000000) + 'Tr';
                                    if(value >= 1000) return (value/1000) + 'k';
                                    return value;
                                }
                            }
                        }
                    }
                }
            });
        });
    </script>
</asp:Content>