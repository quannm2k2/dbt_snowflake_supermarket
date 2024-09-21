# Giới thiệu về `dbt_meta_testing`

**`dbt_meta_testing`** là một gói mở rộng mạnh mẽ được thiết kế dành riêng cho DBT, cung cấp khả năng tự động hóa các quy trình kiểm tra chất lượng dữ liệu và tài liệu hóa (documentation) trong các dự án DBT. Mặc dù DBT tích hợp sẵn nhiều kiểm thử, nhưng khi quy mô dự án tăng lên và số lượng mô hình dữ liệu phát triển, việc kiểm soát chất lượng dữ liệu thông qua các test và quy tắc trở nên phức tạp. **`dbt_meta_testing`** ra đời để giải quyết những thách thức này.

### **Chức năng chính**

1. **Đảm bảo tuân thủ kiểm thử bắt buộc**
    - `+required_tests`
    - Bạn có thể định nghĩa các kiểm thử bắt buộc cho các mô hình, đảm bảo rằng mọi cột trong mô hình đều được kiểm tra theo yêu cầu của dự án.
2. **Bắt buộc tài liệu hóa (documentation)**
    - `+required_docs`
    - Đảm bảo rằng mọi mô hình và cột trong DBT đều có tài liệu mô tả chi tiết
    - Điều này giúp đảm bảo tính minh bạch và hiểu biết toàn diện về các mô hình dữ liệu.
3. **Tự động hóa và kiểm soát tốt hơn**
    - Không còn phải lo lắng về việc bỏ sót các kiểm thử quan trọng, vì **`dbt_meta_testing`** sẽ kiểm tra và cảnh báo nếu bất kỳ mô hình nào không đáp ứng đủ các yêu cầu đặt ra.

### **Ưu điểm**

- **Tự động hóa kiểm thử và tài liệu hóa**: Không cần phải kiểm tra thủ công từng mô hình, giúp tiết kiệm thời gian và công sức.
- **Nâng cao chất lượng dữ liệu**: Kiểm tra liên tục giúp phát hiện và sửa lỗi sớm, đảm bảo tính nhất quán và toàn vẹn của dữ liệu.
- **Khả năng tùy biến linh hoạt**: Người dùng có thể quy định các yêu cầu kiểm thử chi tiết cho từng mô hình, cột hoặc toàn bộ dự án.

### **Nhược điểm**

- **Phức tạp trong thiết lập ban đầu**: Đối với các dự án lớn hoặc nhiều mô hình, việc thiết lập các quy tắc có thể cần nhiều thời gian.
- **Cần hiểu rõ về cấu trúc kiểm thử của DBT**: Nếu bạn không quen với cách DBT hoạt động, việc áp dụng `dbt_meta_testing` có thể trở nên khó khăn.

### So sánh `dbt_meta_testing` với `dbt test`

| Tính năng | `dbt_meta_testing` | `dbt test` |
| --- | --- | --- |
| Mục đích | So sánh kiểm tra yêu cầu và đã cấu hình | Thực thi các kiểm tra dữ liệu |
| Nơi cấu hình chính | `dbt_project.yml` `model config` | `schema.yml` |
| Chức năng chính | Đảm bảo đủ kiểm tra tối thiểu cho từng mô hình | Chạy các kiểm tra đã định nghĩa |
| Kết quả | Báo lỗi nếu thiếu kiểm tra | Báo lỗi nếu dữ liệu không thỏa mãn kiểm tra |
- **Lưu ý:**
    - **`dbt test`** là cơ chế chính để kiểm tra tính hợp lệ của dữ liệu.
    - **`dbt_meta_testing`** không thay thế **`dbt test`**, nó chỉ bổ sung để kiểm tra sự đầy đủ của các kiểm tra đã cấu hình.
    - Vậy nên cần hiểu cách sử dụng `dbt test` trước khi bắt tay vào tìm hiểu `dbt_meta_testing`

# Cài đặt và cấu hình

### Cài đặt

- Thêm vào `package.yml` :
    
    ```sql
    // dbt version required: >= 1.0.0
    packages:
      - package: tnightengale/dbt_meta_testing
        version: 0.3.6
    ```
    

### Cấu hình

- `dbt_meta_testing` gồm 2 tính năng chính:
    - `+required_tests`
    - `+required_docs`

### Required Tests

- Giúp dự án đảm bảo và tuân thủ kiểm thử `*(dbt test)*` bắt buộc
- So sánh kiểm tra yêu cầu và đã cấu hình
- Cấu hình `+required_tests` phải là `None` hoặc một `dict` có khóa `str` và giá trị `int`
    
    
    - Ở đây, bạn có thể sử dụng một số biểu thức chính quy (regex)
    
    ```yaml
    # dbt_project.yml
    ...
    models:
      dbt_snowflake_supermarket:
        +required_docs: true
        staging:
          +required_tests: {"unique": 1, "not_null": 1}
        marts:
          +required_tests: {"unique": 1, "not_null": 1}
          customer_order_summary:
            +required_tests:
              "check.*|unique": 1
              "not_null": 2
              ".*data_test": 1
              "test_customer_order_summary": 1
              
          # starts with "check.*" OR ends with "data_test" (note the ".*" regex suffix) OR (note the "|" regex) 
          # Schema tests are matched against their common names, (eg. not_null, unique, ...).
    			# Custom schema tests are matched against their name, eg. test_customer_order_summary:
    ```
    
- Giống như các cấu hình DBT thông thường. Ta cũng có thể cấu hình ghi đè nên `dbt_project.yml` từ các model:
    
    ```sql
    # /models/marts/store_sales_summary.sql
    -- This overrides the config in dbt_project.yml, and this model will not require tests
    {{ config(required_docs=false, required_tests=None) }}
    
    WITH store_sales AS (
    ...
    ```
    
- Các model không đáp ứng mức tối thiểu của thử nghiệm đã định cấu hình do chúng thiếu thử nghiệm hoặc không được ghi lại sẽ bị liệt vào danh sách lỗi khi được xác thực thông qua thao tác chạy `run-operation`
    
    ```powershell
    PS C:\Users\Admin\dbt_snowflake_supermarket> dbt run-operation required_tests
    16:53:15  Running with dbt=1.8.3
    16:53:16  Registered adapter: snowflake=1.8.3
    16:53:17  Found 6 models, 5 seeds, 37 data tests, 4 sources, 598 macros
    16:53:17  Checking `required_tests` config...
    16:53:18  Encountered an error while running operation: Compilation Error in macro required_tests (macros\required_tests.sql)
      Insufficient test coverage from the 'required_tests' config on the following models:
      - Model: 'customer_order_summary' Test: '.*data_test' Got: 0 Expected: 1
      - Model: 'customer_order_summary' Test: 'test_customer_order_summary' Got: 0 Expected: 1
    
      > in macro default__format_raise_error (macros\utils\formatters\format_raise_error.sql)
      > called by macro format_raise_error (macros\utils\formatters\format_raise_error.sql)
      > called by macro default__required_tests (macros\required_tests.sql)
      > called by macro required_tests (macros\required_tests.sql)
      > called by macro required_tests (macros\required_tests.sql)
    PS C:\Users\Admin\dbt_snowflake_supermarket> 
    ```
    

### Required Docs

- Đảm bảo rằng mọi mô hình và cột trong DBT đều có tài liệu mô tả chi tiết giúp đảm bảo tính minh bạch, toàn diện
- Cấu hình `+required_docs` phải là kiểu `bool`
- Khi áp dụng non-ephemeral model, cần đảm bảo 3 điều sau
    - Model không được trống phần mô tả `(description)`
    - Columns trong mô hình phải định chỉ định trong file `.yml`
    - Columns được chỉ định không được trống phần mô tả `(description)`
    
    ```yaml
    # dbt_project.yml
    ...
    models:
        dbt_snowflake_supermarket:
            +required_docs: true
    ```
    
    ```sql
    # models/schema.yml
    version: 2
    
    models:
      - name: stg_customers
        description: ""
        columns:
          - name: customer_id
            description: ""
            tests:
              - unique
              - not_null
          - name: email
            description: "Customer's email address"
            tests:
              - not_null
          - name: phone_number
            description: "Customer's phone number"
            tests:
              - not_null
          - name: registered_at
            description: "Date the customer was registered"
            tests:
              - not_null
    ...
    ```
    
- Nếu không đáp ứng một trong các yêu cầu trên, sẽ dẫn đến lỗi sau khi được xác thực thông qua thao tác chạy `run-operation` :
    
    ```powershell
    PS C:\Users\Admin\dbt_snowflake_supermarket> dbt run-operation required_docs 
    17:04:18  Running with dbt=1.8.3
    17:04:19  Registered adapter: snowflake=1.8.3
    17:04:20  Found 6 models, 5 seeds, 30 data tests, 4 sources, 598 macros
    17:04:20  Checking `required_docs` config...
    17:04:22  Encountered an error while running operation: Compilation Error in macro required_docs (macros\required_docs.sql)
      The following models are missing descriptions:
       - stg_customers
      The following columns are missing from the model yml:
       - stg_customers.full_name
      The following columns are missing descriptions:
       - stg_customers.customer_id
    
      > in macro default__format_raise_error (macros\utils\formatters\format_raise_error.sql)
      > called by macro format_raise_error (macros\utils\formatters\format_raise_error.sql)
      > called by macro default__required_docs (macros\required_docs.sql)
      > called by macro required_docs (macros\required_docs.sql)
      > called by macro required_docs (macros\required_docs.sql)
    PS C:\Users\Admin\dbt_snowflake_supermarket> 
    ```
    

# Một số lệnh CLI

### Lệnh `required_tests`

- Kiểm tra xem các mô hình có đáp ứng yêu cầu kiểm thử hay không.
    
    ```bash
    dbt run-operation required_tests
    ```
    

### Lệnh `required_docs`

- Đảm bảo rằng mọi mô hình và cột trong DBT đều có tài liệu mô tả chi tiết giúp đảm bảo tính minh bạch, toàn diện
    
    ```bash
    dbt run-operation required_docs
    ```
    
- **Lưu ý:**
    - **Lệnh này chỉ nên chạy sau khi `dbt run`**: Vì lệnh kiểm tra tài liệu yêu cầu rằng mô hình đã tồn tại trong warehouse (kho dữ liệu) trước khi kiểm tra xem các cột có thiếu tài liệu trong **`schema.yml`** không

### Kiểm tra một số mô hình chỉ định

- Bạn có thể kiểm tra cấu hình chỉ cho một tập hợp con các mô hình (ví dụ: các mô hình mới trong quá trình CI/CD) bằng cách truyền đối số **`models`** vào macro. Đối số này là một chuỗi chứa tên của các mô hình, được phân tách bằng khoảng trắng.
    
    ```bash
    dbt run-operation required_tests --args "{'models':'model1 model2 model3'}"
    ```
    

### **Sử dụng kết quả từ lệnh `dbt ls`**

- Bạn cũng có thể sử dụng lệnh **`dbt ls -m <selection_syntax>`** để chọn các mô hình cụ thể dựa trên cú pháp chọn node của DBT. Sau đó, sử dụng kết quả của lệnh này làm đối số cho **`required_tests`** hoặc **`required_docs`**.
- Ví dụ để chạy kiểm tra chỉ cho các mô hình đã thay đổi (modified) bằng tính năng Slim CI của DBT:
    
    ```bash
    dbt run-operation required_tests --args "{'models':'$(dbt list -m state:modified --state <filepath>)'}"
    ```
