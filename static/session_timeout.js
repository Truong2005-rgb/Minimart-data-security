/* MiniMart: tự động phát hiện phiên hết hạn trên trang Home.
   Nguồn quyết định quyền truy cập luôn là Flask (/home), không phải đồng hồ JS.
   Không fetch/ping định kỳ vì việc đó sẽ vô tình gia hạn idle timeout ở server.
*/
(() => {
  'use strict';
  const display = document.getElementById('session-timer');
  if (!display) return;
  const idleSeconds = Number(display.dataset.idleSeconds);
  const absoluteRemainingSeconds = Number(display.dataset.absoluteRemainingSeconds);
  const checkUrl = display.dataset.checkUrl || '/home';
  if (!Number.isFinite(idleSeconds) || idleSeconds <= 0 ||
      !Number.isFinite(absoluteRemainingSeconds) || absoluteRemainingSeconds <= 0) {
    // Cấu hình thiếu thì không tin đồng hồ client; kiểm tra lại trên server.
    window.location.replace(checkUrl);
    return;
  }

  // performance.now() là đồng hồ đơn điệu, tránh việc chỉnh giờ hệ thống.
  // Thời hạn idle được tính từ lần yêu cầu /home vừa được server xác thực;
  // thời hạn tuyệt đối không được gia hạn dù F5 nhiều lần.
  const deadline = performance.now() +
    Math.min(idleSeconds, absoluteRemainingSeconds) * 1000;
  let navigating = false;
  const tick = () => {
    if (navigating) return;
    const remaining = deadline - performance.now();
    if (remaining <= 0) {
      navigating = true;
      // /home tự xóa phiên hết hạn, ghi AuthLog rồi đưa về /login?reason=idle
      // (hoặc reason=absolute). KHÔNG tự quyết định quyền ở phía JS.
      window.location.replace(checkUrl);
      return;
    }
  };
  tick();
  window.setInterval(tick, 1000);
  // Bộ đếm có thể bị trì hoãn khi tab nằm nền; cập nhật khi quay lại tab.
  window.addEventListener('focus', tick);
  document.addEventListener('visibilitychange', tick);
  // Khi đi Back tới một trang Home phục hồi từ bfcache, phải kiểm tra lại
  // trực tiếp trên server (kể cả người dùng đã logout từ tab khác).
  window.addEventListener('pageshow', (event) => {
    if (event.persisted && !navigating) {
      navigating = true;
      window.location.replace(checkUrl);
    } else {
      tick();
    }
  });
})();
