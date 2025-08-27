#!/bin/bash

# Dừng script ngay nếu có lỗi
set -e

echo "--- [BẮT ĐẦU] Kiểm tra các công cụ có sẵn trong môi trường build ---"
echo ""

# Danh sách các lệnh cần kiểm tra
COMMANDS_TO_CHECK="python3 pip bash sh apt apt-get yum dnf node npm yarn pnpm git curl wget"

for cmd in $COMMANDS_TO_CHECK; do
  echo "--- Đang kiểm tra: $cmd ---"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "✅ '$cmd' có sẵn."
    
    # Lấy đường dẫn tuyệt đối
    CMD_PATH=$(command -v "$cmd")
    echo "   Path: $CMD_PATH"

    # Cố gắng lấy phiên bản (version)
    # Mỗi lệnh có cờ version khác nhau, vì vậy chúng ta cần xử lý riêng
    VERSION_OUTPUT=""
    case "$cmd" in
      python3|pip|git|curl|node|npm|yarn|pnpm)
        VERSION_OUTPUT=$($cmd --version 2>&1 | head -n 1)
        ;;
      bash|sh)
        VERSION_OUTPUT=$($cmd --version 2>&1 | head -n 1)
        ;;
      yum)
        # Yum không có cờ version dễ dàng, nhưng ta có thể kiểm tra package
        VERSION_OUTPUT=$(yum --version 2>&1 | head -n 1)
        ;;
    esac
    
    if [ -n "$VERSION_OUTPUT" ]; then
      echo "   Version: $VERSION_OUTPUT"
    fi

  else
    echo "❌ '$cmd' KHÔNG có sẵn."
  fi
  echo "" # Thêm một dòng trống để dễ đọc
done

echo "--- [KẾT THÚC] Kiểm tra hoàn tất ---"
