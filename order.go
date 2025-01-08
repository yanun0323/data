package binance

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"time"
)

type OrderResponse struct {
	Symbol        string `json:"symbol"`
	OrderID       int64  `json:"orderId"`
	ClientOrderID string `json:"clientOrderId"`
	Price         string `json:"price"`
	Status        string `json:"status"`
}

func CreateOrder(apiKey string, secretKey string, symbol string, side string, orderType string, quantity string, price string) (*OrderResponse, error) {
	// 1. 準備請求參數
	baseURL := "https://api.binance.com"
	endpoint := "/api/v3/order"

	timestamp := strconv.FormatInt(time.Now().UnixMilli(), 10)

	params := url.Values{}
	params.Add("symbol", symbol)
	params.Add("side", side)      // "BUY" or "SELL"
	params.Add("type", orderType) // "LIMIT", "MARKET" etc
	params.Add("quantity", quantity)
	params.Add("timestamp", timestamp)

	if orderType == "LIMIT" {
		params.Add("price", price)
		params.Add("timeInForce", "GTC")
	}

	// 2. 產生簽名
	payload := params.Encode()
	h := hmac.New(sha256.New, []byte(secretKey))
	h.Write([]byte(payload))
	signature := hex.EncodeToString(h.Sum(nil))

	// 3. 建立完整 URL
	fullURL := fmt.Sprintf("%s%s?%s&signature=%s", baseURL, endpoint, payload, signature)

	// 4. 建立 HTTP 請求
	req, err := http.NewRequest("POST", fullURL, nil)
	if err != nil {
		return nil, err
	}

	// 5. 加入 API Key header
	req.Header.Add("X-MBX-APIKEY", apiKey)

	// 6. 發送請求
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	// 7. 讀取回應
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	// 8. 檢查 HTTP 狀態碼
	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("API 錯誤: %s", string(body))
	}

	// 9. 解析 JSON 回應
	var orderResp OrderResponse
	err = json.Unmarshal(body, &orderResp)
	if err != nil {
		return nil, err
	}

	return &orderResp, nil
}

// 使用範例:
func main() {
	apiKey := "你的API金鑰"
	secretKey := "你的密鑰"

	resp, err := CreateOrder(
		apiKey,
		secretKey,
		"BTCUSDT", // 交易對
		"BUY",     // 買入
		"LIMIT",   // 限價單
		"0.001",   // 數量
		"35000",   // 價格
	)

	if err != nil {
		fmt.Printf("下單錯誤: %v\n", err)
		return
	}

	fmt.Printf("下單成功: %+v\n", resp)
}
