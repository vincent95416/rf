import requests
import pytest

DOMAIN = "192.168.11.26"
COMMUNITY_ID = "00000000-0000-0000-0000-000000000000"
BUILDING_ID = "60b1dacd-4efa-41b3-9b8a-7ded83ae6dec"
FLOOR_ID = "5d57df17-284c-46fc-9f79-8d133bd80574"

@pytest.fixture(scope="session")
def base_url():
    return f"http://{DOMAIN}/api/v1"
@pytest.fixture(scope="session")
def token():
    url = f"http://{DOMAIN}/user/login"
    payload = {
        "acc": "admin",
        "pwd": "P@ssw0rd"
    }
    try:
        response = requests.post(url, json=payload)
        token = response.json()['token']
        if not token:
            pytest.fail('token取得失敗')
        return token
    except requests.exceptions.RequestException as e:
        pytest.fail(f'登入失敗: {e}')