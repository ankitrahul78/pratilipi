import requests
import boto3
from flask import Flask
from flask_restful import Api,Resource,reqparse
import pandas as pd

app = Flask(__name__)
api = Api(app)

# video_put_args = reqparse.RequestParser()
# video_put_args.add_argument('name',type=str,help="Name is missing")
# video_put_args.add_argument('views',type=str,help="views is missing")
# video_put_args.add_argument('likes',type=str,help="likes is missing")
client = boto3.client(
    's3',
    aws_access_key_id = 'XXXXXXXXXXXX',
    aws_secret_access_key = 'XXXXXXXXXXXXXX',
    region_name = 'ap-south-1'
)
# videos = {}
class FetchObject(Resource):
    def get(self):
        obj = client.get_object(
        Bucket = 'pratilipi-ankit',
        Key = 'file.csv'
    )
        data = pd.read_csv(obj['Body'])
    # Print the data frame
        print('Printing the data frame...')
        print(data)
        return data.to_json()


api.add_resource(FetchObject, "/api")

if __name__ == "__main__":
    app.run(debug=True)