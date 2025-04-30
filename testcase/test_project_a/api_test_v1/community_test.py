import requests
import pytest
from conf_test import COMMUNITY_ID, BUILDING_ID, FLOOR_ID, base_url, token

@pytest.fixture(scope="session")
def auth_headers(token):
    return {"Authorization": token}

def test_community_list(base_url, auth_headers):
    url = f"{base_url}/communities"
    response = requests.get(url, headers=auth_headers)
    assert response.status_code == 200
    assert response.json()['result'] == 0
    assert "data" in response.json()

def test_community_info(base_url, auth_headers):
    url = f"{base_url}/communities/{COMMUNITY_ID}"
    response = requests.get(url, headers=auth_headers)
    assert response.status_code == 200
    assert response.json()['result'] == 0
    assert "data" in response.json()

class TestBuildingOperations:
    build_id= None

    @pytest.fixture(scope='class')
    def import_building_and_floor(self, base_url, auth_headers):
        payload = {
            "households": [
                {
                    "name": "十殿閻君",
                    "buildingName": "桃豬引原",
                    "floorName": "阿鼻獄"
                }
            ]
        }
        url = f"{base_url}/communities/{COMMUNITY_ID}/households/import"
        response = requests.post(url, headers=auth_headers, json=payload)
        assert response.status_code == 200
        assert response.json()['result'] == 0
        assert "data" in response.json()
        url = f"{base_url}/communities/{COMMUNITY_ID}/buildings"
        response = requests.get(url, headers=auth_headers)
        assert response.status_code == 200
        assert response.json()['result'] == 0
        assert "data" in response.json()
        #找building列表
        fetch_url = f"{base_url}/communities/{COMMUNITY_ID}/buildings"
        fetch_response = requests.get(fetch_url, headers=auth_headers)
        assert fetch_response.status_code == 200
        assert fetch_response.json()['result'] == 0

        building_list = fetch_response.json()['data']['buildingList']
        if building_list:
            for building in building_list:
                if building.get("name") == "桃豬引原":
                    self.build_id = building.get("id")
                    assert self.build_id is not None
                    break
            if not self.build_id:
                pytest.fail('無法找到新建立的buildingName')
        else:
            pytest.fail('building_list不存在')

        yield self.build_id

        if self.build_id:
            del_url = f"{base_url}/communities/{COMMUNITY_ID}/buildings?buildingIds={self.build_id}"
            response = requests.delete(del_url, headers=auth_headers)
            assert response.status_code == 200
            assert response.json()['result'] == 0

    def test_floor_list(self, base_url, auth_headers, import_building_and_floor):
        url = f"{base_url}/communities/{COMMUNITY_ID}/buildings/{import_building_and_floor}/floors"
        response = requests.get(url, headers=auth_headers)
        assert response.status_code == 200
        assert response.json()['result'] == 0
        assert "data" in response.json()

    def test_house_list_for_building(self, base_url, auth_headers):
        url = f"{base_url}/communities/{COMMUNITY_ID}/households/building"
        response = requests.get(url, headers=auth_headers)
        assert response.status_code == 200
        assert response.json()['result'] == 0
        assert "data" in response.json()

class TestHouseOperations:
    house_id = None
    house_code = None

    @pytest.fixture(scope="class")
    def create_house(self, base_url, auth_headers):
        url = f"{base_url}/communities/{COMMUNITY_ID}/households"
        payload = {
            "name": "JoeJoe的奇妙冒險",
            "buildingId": BUILDING_ID,
            "floorId": FLOOR_ID,
            "headOfHouseholdId": "6aae7b2d-eb4d-4569-b016-203caf92d259",
            "parkingSlots": "556"
        }
        response = requests.post(url, headers=auth_headers, json=payload)
        assert response.status_code == 200
        assert response.json()['result'] == 0
        # 找house列表
        fetch_url = f"{base_url}/communities/{COMMUNITY_ID}/households?buildingId={BUILDING_ID}&floorId={FLOOR_ID}"
        fetch_response = requests.get(fetch_url, headers=auth_headers)
        assert fetch_response.status_code == 200
        assert fetch_response.json()['result'] == 0

        house_list = fetch_response.json()['data']['householdList']
        if house_list:
            for house in house_list:
                if house.get("name") == "JoeJoe的奇妙冒險":
                    self.house_id = house.get("id")
                    self.house_code = house.get("householdCodeString")
                    assert self.house_id is not None
                    assert self.house_code is not None
                    break
            if not self.house_id:
                pytest.fail('無法找到新建立的houseName')
        else:
            pytest.fail('house_list不存在')

        yield self.house_id, self.house_code

        if self.house_id:
            del_url = f"{base_url}/communities/{COMMUNITY_ID}/households/{self.house_id}"
            response = requests.delete(del_url, headers=auth_headers)
            assert response.status_code == 200
            assert response.json()['result'] == 0

    def test_edit_house(self, base_url, auth_headers, create_house):
        house_id, house_code = create_house
        url = f"{base_url}/communities/{COMMUNITY_ID}/households/{house_id}"
        payload = {
            "name": "r",
            "buildingId": "",
            "floorId": "",
            "headOfHouseholdId": "",
            "parkingSlots": "1"
        }
        response = requests.put(url, headers=auth_headers, json=payload)
        assert response.status_code == 200
        assert response.json()['result'] == 0

    def test_members(self, base_url, auth_headers, create_house):
        house_id, house_code = create_house
        url = f"{base_url}/userHousehold/{house_id}/members"
        response = requests.get(url, headers=auth_headers)
        assert response.status_code == 200
        assert response.json()['result'] == 0
        assert "data" in response.json()

    def test_postal_list_for_house(self, base_url, auth_headers, create_house):
        house_id, house_code = create_house
        url = f"{base_url}/communities/{COMMUNITY_ID}/postManagement/{house_id}?pageSize=10&status=unclaimed"
        response = requests.get(url, headers=auth_headers)
        assert response.status_code == 200
        assert response.json()['result'] == 0
        assert "data" in response.json()

    def test_assign(self, base_url, auth_headers, create_house):
        house_id, house_code = create_house
        url = f"{base_url}/userHousehold/assign"
        payload = {"householdCodeString": house_code}
        response = requests.post(url, headers=auth_headers, json=payload)
        assert response.status_code == 200
        assert response.json()['result'] == 0

    def test_unassign(self, base_url, auth_headers, create_house):
        house_id, house_code = create_house
        user_id = "6aae7b2d-eb4d-4569-b016-203caf92d259"
        url = f"{base_url}/userHousehold/web/{house_id}/unassign/{user_id}"
        response = requests.delete(url, headers=auth_headers)
        assert response.status_code == 200
        assert response.json()['result'] == 0


class TestPostalManagement:
    postal_id = None

    @pytest.fixture(scope="class")
    def create_post(self, base_url, auth_headers):
        url = f"{base_url}/communities/{COMMUNITY_ID}/postManagement"
        payload = {
            "type": 1,
            "status": 1,
            "subType": 1,
            "trackingNumber": "",
            "logisticsCompanyId": "",
            "locationId": "",
            "imageUrl": "",
            "remark": "郵差",
            "recipientHouseholdId": "95487d5b-6464-44a5-bc86-70fe012957d6",
            "visitorName": "",
            "visitorPhone": "",
            "depositorHouseholdId": "",
            "returnerHouseholdId": ""
        }
        response = requests.post(url, headers=auth_headers, json=payload)
        assert response.status_code == 200
        assert response.json()['result'] == 0
        # 找post列表
        fetch_url = f"{base_url}/communities/{COMMUNITY_ID}/postManagement"
        fetch_response = requests.get(fetch_url, headers=auth_headers)
        postal_list = fetch_response.json()['data']['postManagementDTOList']
        if postal_list:
            for post in postal_list:
                if post.get("remark") == "郵差":
                    self.postal_id = post.get("id")
                    assert self.postal_id is not None
                    break
            if not self.postal_id:
                pytest.fail('新建立的post不存在')
        else:
            pytest.fail('postManagementDTOList不存在')

        yield self.postal_id

        if self.postal_id:
            del_url = f"{base_url}/communities/{COMMUNITY_ID}/postManagement/{self.postal_id}"
            response = requests.delete(del_url, headers=auth_headers)
            assert response.status_code == 200
            assert response.json()['result'] == 0

    def test_postal_info(self, base_url, auth_headers, create_post):
        postal_id = create_post
        url = f"{base_url}/communities/{COMMUNITY_ID}/postManagement/{postal_id}"
        response = requests.get(url, headers=auth_headers)
        assert response.status_code == 200
        assert response.json()['result'] == 0
        assert "data" in response.json()

    def test_edit_post(self, base_url, auth_headers, create_post):
        postal_id = create_post
        url = f"{base_url}/communities/{COMMUNITY_ID}/postManagement/{postal_id}"
        payload = {
            "type": 1,
            "subType": 1,
            "trackingNumber": "",
            "logisticsCompanyId": "",
            "locationId": "",
            "imageUrl": "",
            "remark": "",
            "recipientHouseholdId": "95487d5b-6464-44a5-bc86-70fe012957d6",
            "visitorName": "",
            "visitorPhone": "",
            "depositorHouseholdId": "",
            "returnerHouseholdId": ""
        }
        response = requests.put(url, headers=auth_headers, json=payload)
        assert response.status_code == 200
        assert response.json()['result'] == 0

    def test_pickup_post(self, base_url, auth_headers, create_post):
        postal_id = create_post
        url = f"{base_url}/communities/{COMMUNITY_ID}/postManagement/{postal_id}"
        payload = {"status": "pickedUp"}
        response = requests.patch(url, headers=auth_headers, json=payload)
        assert response.status_code == 200
        assert response.json()['result'] == 0

    def test_logistics_list(self, base_url, auth_headers):
        url = f"{base_url}/communities/{COMMUNITY_ID}/logistics"
        response = requests.get(url, headers=auth_headers)
        assert response.status_code == 200
        assert response.json()['result'] == 0
        assert "data" in response.json()

    def test_location_list(self, base_url, auth_headers):
        url = f"{base_url}/communities/{COMMUNITY_ID}/locations"
        response = requests.get(url, headers=auth_headers)
        assert response.status_code == 200
        assert response.json()['result'] == 0
        assert "data" in response.json()

class TestAnnouncement:
    announce_id = None

    @pytest.fixture(scope="class")
    def create_announce(self, base_url, auth_headers):
        url = f"{base_url}/communities/{COMMUNITY_ID}/communityAnnouncements"
        payload = {
          "title": "查無不法謝謝指教",
          "type": 1,
          "effectiveFrom": "2024-01-13T00:00:00Z",
          "effectiveTo": "",
          "content": "死人連署",
          "imageUrl": "",
          "pinned": 1,
          "status": 2
        }
        response = requests.post(url, headers=auth_headers, json=payload)
        assert response.status_code == 200
        assert response.json()['result'] == 0

        fetch_url = f"{base_url}/communities/{COMMUNITY_ID}/communityAnnouncements"
        fetch_response = requests.get(fetch_url, headers=auth_headers)
        assert fetch_response.status_code == 200
        assert fetch_response.json()['result'] == 0
        assert "data" in fetch_response.json()
        announce_list = fetch_response.json()['data']['communityAnnouncementList']
        if announce_list:
            for announce in announce_list:
                if announce.get('title') == "查無不法謝謝指教":
                    self.announce_id = announce.get('id')
                    assert self.announce_id is not None
                    break
            if not self.announce_id:
                pytest.fail('新建立的announce不存在')
        else:
            pytest.fail('communityAnnouncementList不存在')

        yield self.announce_id

        if self.announce_id:
            del_url = f"{base_url}/communities/{COMMUNITY_ID}/communityAnnouncements/{self.announce_id}"
            del_response = requests.delete(del_url, headers=auth_headers)
            assert del_response.status_code == 200
            assert del_response.json()['result'] == 0

    def test_edit_announce(self, base_url, auth_headers, create_announce):
        announce_id = create_announce
        url = f"{base_url}/communities/{COMMUNITY_ID}/communityAnnouncements/{announce_id}"
        payload = {
          "title": "查無不法謝謝指教",
          "type": 3,
          "effectiveFrom": "2024-01-13T00:00:00Z",
          "effectiveTo": "",
          "content": "死人連署",
          "imageUrl": "",
          "pinned": 1,
          "status": 3
        }
        response = requests.put(url, headers=auth_headers, json=payload)
        assert response.status_code == 200
        assert response.json()['result'] == 0

    def test_announce_list_for_app(self, base_url, auth_headers):
        url = f"{base_url}/communities/{COMMUNITY_ID}/communityAnnouncements/userReadStatus"
        response = requests.get(url, headers=auth_headers)
        assert response.status_code == 200
        assert response.json()['result'] == 0
        assert "data" in response.json()