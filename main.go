package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/redis/go-redis/v9"
)

func main() {
	// 建立 Redis Cluster 客戶端
	rdb := redis.NewClusterClient(&redis.ClusterOptions{
		Addrs: []string{
			"localhost:7001",
			"localhost:7002",
			"localhost:7003",
			"localhost:7004",
			"localhost:7005",
			"localhost:7006",
		},
		// 設定連線池參數
		PoolSize:     10,
		MinIdleConns: 5,
		// 設定超時時間
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 5 * time.Second,
		DialTimeout:  5 * time.Second,
	})
	defer rdb.Close()

	ctx := context.Background()

	// 測試連線
	err := rdb.Ping(ctx).Err()
	if err != nil {
		log.Fatalf("無法連接到 Redis Cluster: %v", err)
	}
	fmt.Println("成功連接到 Redis Cluster!")

	// 測試寫入
	err = rdb.Set(ctx, "test_key", "測試值", 0).Err()
	if err != nil {
		log.Fatalf("寫入失敗: %v", err)
	}
	fmt.Println("成功寫入測試值")

	// 測試讀取
	val, err := rdb.Get(ctx, "test_key").Result()
	if err != nil {
		log.Fatalf("讀取失敗: %v", err)
	}
	fmt.Printf("讀取到的值: %s\n", val)
}
