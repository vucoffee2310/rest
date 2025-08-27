#!/bin/bash

# Dừng script ngay nếu có lỗi
set -e

echo "--- [BẮT ĐẦU] Kiểm tra và cài đặt các công cụ cần thiết ---"
echo "Môi trường build sử dụng trình quản lý gói YUM."
echo ""

# Danh sách các lệnh cần kiểm tra
# Lưu ý: apt, apt-get, dnf sẽ không có sẵn và không thể cài đặt.
COMMANDS_TO_CHECK="python3 pip bash sh apt apt-get yum dnf node npm yarn pnpm git curl wget"

for cmd in $COMMANDS_TO_CHECK; do
  echo "--- Đang kiểm tra: $cmd ---"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "✅ '$cmd' đã có sẵn."
    # Lấy phiên bản nếu có thể
    $cmd --version 2>&1 | head -n 1 || true
  else
    echo "⚠️  '$cmd' KHÔNG có sẵn. Đang thử cài đặt..."
    
    # Mặc định, tên gói giống tên lệnh
    PACKAGE_NAME="$cmd"
    INSTALL_COMMAND=""

    # Xử lý các trường hợp đặc biệt
    case "$cmd" in
      pip)
        # Pip thường đi kèm với gói python3-pip
        PACKAGE_NAME="python3-pip"
        INSTALL_COMMAND="sudo yum install -y $PACKAGE_NAME"
        ;;
      pnpm)
        # pnpm được cài đặt thông qua npm, không phải yum
        echo "   Cài đặt pnpm bằng npm..."
        INSTALL_COMMAND="npm install -g pnpm"
        ;;
      apt|apt-get|dnf|yum|bash|sh|node|npm|yarn)
        # Đây là các công cụ hệ thống hoặc được Vercel quản lý, không nên/thể cài đặt
        echo "❌ '$cmd' là công cụ hệ thống hoặc không được hỗ trợ để cài đặt thủ công. Bỏ qua."
        INSTALL_COMMAND="skip"
        ;;
      *)
        # Đối với các trường hợp khác, dùng yum
        INSTALL_COMMAND="sudo yum install -y $PACKAGE_NAME"
        ;;
    esac

    # Thực thi lệnh cài đặt nếu có
    if [ "$INSTALL_COMMAND" != "" ] && [ "$INSTALL_COMMAND" != "skip" ]; then
      if $INSTALL_COMMAND; then
        echo "   Cài đặt thành công!"
        # Kiểm tra lại sau khi cài đặt
        if command -v "$cmd" >/dev/null 2>&1; then
          echo "✅ '$cmd' hiện đã có sẵn."
          $cmd --version 2>&1 | head -n 1 || true
        else
          echo "❌ Lỗi: Vẫn không tìm thấy '$cmd' sau khi cài đặt."
          exit 1
        fi
      else
        echo "❌ Cài đặt '$cmd' thất bại."
        exit 1 # Thoát build vì dependency quan trọng bị thiếu
      fi
    fi
  fi
  echo "" # Thêm dòng trống để dễ đọc
done

echo "--- [KẾT THÚC] Kiểm tra và cài đặt hoàn tất ---"
