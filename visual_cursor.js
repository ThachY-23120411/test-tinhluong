/**
 * Visual Mouse Cursor & Action Streamer for Antigravity Live Browser
 * Tự động hiển thị con trỏ chuột ảo trực quan, hiệu ứng click gợn sóng (ripple)
 * và chỉ báo gõ phím trực tiếp trên màn hình trình duyệt để người dùng theo dõi livestream.
 */
(function initVisualCursor() {
  if (window.__antigravity_cursor_injected__) return;
  window.__antigravity_cursor_injected__ = true;

  function setupElements() {
    if (document.getElementById('__ag_cursor__')) return;

    // 1. Nhúng Style cho Cursor, Ripple và Typing Badge
    const style = document.createElement('style');
    style.id = '__antigravity_cursor_style__';
    style.innerHTML = `
      #__ag_cursor__ {
        position: fixed;
        top: 0;
        left: 0;
        width: 26px;
        height: 26px;
        pointer-events: none;
        z-index: 2147483647;
        transform: translate3d(-100px, -100px, 0);
        transition: none !important;
        will-change: transform;
        filter: drop-shadow(0 2px 5px rgba(0, 0, 0, 0.45));
      }
      #__ag_cursor__ svg {
        width: 100%;
        height: 100%;
      }
      .__ag_ripple__ {
        position: fixed;
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: rgba(225, 29, 72, 0.45);
        border: 2px solid #e11d48;
        pointer-events: none;
        z-index: 2147483646;
        transform: translate(-50%, -50%) scale(0.2);
        animation: __ag_ripple_anim__ 0.38s ease-out forwards;
      }
      @keyframes __ag_ripple_anim__ {
        0% {
          transform: translate(-50%, -50%) scale(0.2);
          opacity: 1;
        }
        100% {
          transform: translate(-50%, -50%) scale(1.6);
          opacity: 0;
        }
      }
      #__ag_typing_badge__ {
        position: fixed;
        display: none;
        padding: 3px 8px;
        background: #1e293b;
        color: #38bdf8;
        font-family: Consolas, Monaco, "Courier New", monospace;
        font-size: 11px;
        font-weight: 600;
        border-radius: 4px;
        border: 1px solid #0284c7;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.35);
        pointer-events: none;
        z-index: 2147483647;
        white-space: nowrap;
        transition: opacity 0.2s ease;
      }
    `;
    const headTarget = document.head || document.documentElement || document.body;
    if (headTarget) headTarget.appendChild(style);

    // 2. Tạo phần tử con trỏ chuột hình mũi tên Neon sắc nét
    const cursor = document.createElement('div');
    cursor.id = '__ag_cursor__';
    cursor.innerHTML = `
      <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M5.5 3.21V20.8c0 .45.54.67.85.35l4.38-4.38a1 1 0 01.71-.29h6.12c.45 0 .67-.54.35-.85L6.35 3.56a.5.5 0 00-.85.35z" 
              fill="#e11d48" stroke="#ffffff" stroke-width="1.8" stroke-linejoin="round"/>
        <circle cx="6" cy="4" r="2.5" fill="#f43f5e" />
      </svg>
    `;

    // 3. Tạo phần tử hiển thị gõ phím (Typing Badge)
    const typingBadge = document.createElement('div');
    typingBadge.id = '__ag_typing_badge__';
    typingBadge.innerText = '⌨️ Typing...';

    const bodyTarget = document.body || document.documentElement;
    if (bodyTarget) {
      bodyTarget.appendChild(cursor);
      bodyTarget.appendChild(typingBadge);
    }

    let mouseX = -100;
    let mouseY = -100;
    let typingTimer = null;

    // Lắng nghe di chuyển chuột
    window.addEventListener('mousemove', (e) => {
      mouseX = e.clientX;
      mouseY = e.clientY;
      cursor.style.transform = `translate3d(${mouseX}px, ${mouseY}px, 0)`;
      if (typingBadge.style.display !== 'none') {
        typingBadge.style.left = `${mouseX + 20}px`;
        typingBadge.style.top = `${mouseY - 24}px`;
      }
    }, { passive: true });

    // Lắng nghe click tạo hiệu ứng sóng tròn (Ripple)
    window.addEventListener('mousedown', (e) => {
      const ripple = document.createElement('div');
      ripple.className = '__ag_ripple__';
      ripple.style.left = `${e.clientX}px`;
      ripple.style.top = `${e.clientY}px`;
      const container = document.body || document.documentElement;
      if (container) container.appendChild(ripple);
      setTimeout(() => ripple.remove(), 400);
    }, { passive: true });

    // Lắng nghe gõ phím để hiển thị bong bóng ký tự trực quan
    window.addEventListener('keydown', (e) => {
      if (['Shift', 'Control', 'Alt', 'Meta'].includes(e.key)) return;
      typingBadge.style.display = 'block';
      typingBadge.innerText = `⌨️ ${e.key.length === 1 ? e.key : `[${e.key}]`}`;
      typingBadge.style.left = `${mouseX + 20}px`;
      typingBadge.style.top = `${mouseY - 24}px`;
      typingBadge.style.opacity = '1';

      clearTimeout(typingTimer);
      typingTimer = setTimeout(() => {
        typingBadge.style.opacity = '0';
        setTimeout(() => { typingBadge.style.display = 'none'; }, 200);
      }, 900);
    }, { passive: true });

    console.log('[Antigravity Visual Cursor] -> Đã kích hoạt livestream con trỏ chuột trực quan.');
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupElements);
  } else {
    setupElements();
  }
})();
