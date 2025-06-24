Feature: Community API Operations
  身為一個管理者
  我能從查詢到社區的相關資訊

  Background:
    Given the API base URL and token are prepared

  Scenario: 取得community list成功
    When I send a GET request to the "/communities" endpoint
    Then the response status code should be 200
    And the response result should be 0
    And the response data should contain "data" key

  Scenario: 成功取得社區資訊
    When I send a GET request to the "/communities/{communities} endpoint
    Then the response status code should be 200
    And the response result should be 0
    And the response data should contain "data" key