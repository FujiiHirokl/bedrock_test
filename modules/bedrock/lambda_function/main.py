import boto3
import json

bedrock_runtime = boto3.client('bedrock-runtime')

def lambda_handler(event, context):
    # プロンプトに設定する内容を取得
    prompt = event.get('prompt')

    # 各種パラメーターの指定
    modelId = 'ai21.j2-mid-v1' 
    accept = 'application/json'
    contentType = 'application/json'

    # リクエストBODYの指定
    body = json.dumps({
        "prompt": prompt,
        "maxTokens": 100,
        "temperature": 0.7,
        "topP": 1,
    })

    # Bedrock APIの呼び出し
    response = bedrock_runtime.invoke_model(
    	modelId=modelId,
    	accept=accept,
    	contentType=contentType,
        body=body
    )

    # APIレスポンスからBODYを取り出す
    response_body = json.loads(response.get('body').read())

    # レスポンスBODYから応答テキストを取り出す
    outputText = response_body.get('completions')[0].get('data').get('text')

    return outputText.encode('utf-8')