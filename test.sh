#!/bin/bash

# Dừng script ngay nếu có lỗi
set -e

echo "--- [BẮT ĐẦU] Kiểm tra và cài đặt các công cụ ---"
echo ""

# Danh sách các lệnh cần kiểm tra
COMMANDS_TO_CHECK="python3 pip bash sh wget yum dnf"

for cmd in $COMMANDS_TO_CHECK; do
  echo "--- Đang kiểm tra: $cmd ---"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "✅ '$cmd' đã có sẵn."
  else
    echo "❌ '$cmd' KHÔNG có sẵn. Đang thử cài đặt..."
    
    # Sử dụng yum để cài đặt vì nó có sẵn
    # Cần map tên lệnh với tên gói
    PACKAGE_NAME=""
    case "$cmd" in
      pip)
        PACKAGE_NAME="python3-pip"
        ;;
      wget)
        PACKAGE_NAME="wget"
        ;;
      *)
        # Bỏ qua nếu không biết cài gói nào
        echo "   ⚠️ Không có quy tắc cài đặt cho '$cmd'. Bỏ qua."
        continue # Chuyển sang lệnh tiếp theo
        ;;
    esac

    echo "   Đang chạy: sudo yum install -y $PACKAGE_NAME"
    if sudo yum install -y "$PACKAGE_NAME"; then
      echo "   ✅ Cài đặt '$PACKAGE_NAME' thành công."
    else
      echo "   🔥 Cài đặt '$PACKAGE_NAME' thất bại."
      exit 1 # Thoát build nếu cài đặt thất bại
    fi
  fi
  echo ""
done

# Giải quyết vấn đề "Output Directory" bằng cách tạo một thư mục rỗng
# Vercel sẽ không triển khai thư mục này vì không có gì trong đó,
# nhưng nó sẽ làm cho bước build thành công.
echo "--- Tạo thư mục output rỗng để tránh lỗi build ---"
mkdir -p public

echo "--- [KẾT THÚC] Kiểm tra hoàn tất ---"
