use aws_sdk_dynamodb as dynamodb;
use chrono::Utc;
use lambda_http::{run, service_fn, Body, Error, Request, RequestExt, Response};
use serde::{Deserialize, Serialize};
use serde_json;

use lib::post::Post;

/// This is the main body for the function.
/// Write your code inside it.
/// There are some code example in the following URLs:
/// - https://github.com/awslabs/aws-lambda-rust-runtime/tree/main/examples
async fn function_handler(
    request: Request,
    dynamodb_client: &dynamodb::Client,
) -> Result<Response<Body>, Error> {
    // Extract some useful information from the request
    let body = request.body();
    let response = match body {
        Body::Empty => bad_request_response(),
        Body::Binary(_) => bad_request_response(),
        Body::Text(body) => {
            let input: Input = serde_json::from_str(body)?;
            let post: Post = Post {
                body: input.text,
                created_at: Utc::now(),
            };

            match post.save(dynamodb_client).await {
                Ok(_) => Ok(Response::builder()
                    .status(201)
                    .header("content-type", "text/html")
                    .body("CREATED".into())
                    .map_err(Box::new)?),
                Err(_) => bad_request_response(),
            }
        }
    };

    response
}

#[derive(Serialize, Deserialize)]
struct Input {
    text: String,
}

fn bad_request_response() -> Result<Response<Body>, Error> {
    Ok(Response::builder()
        .status(400)
        .header("content-type", "text/html")
        .body("".into())
        .map_err(Box::new)?)
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        // disable printing the name of the module in every log line.
        .with_target(false)
        // disabling time is handy because CloudWatch will add the ingestion time.
        .without_time()
        .init();

    let config = ::aws_config::load_from_env().await;
    let dynamodb_client = dynamodb::Client::new(&config);

    // run(service_fn(function_handler)).await
    lambda_http::run(service_fn(|request| {
        function_handler(request, &dynamodb_client)
    }))
    .await?;
    Ok(())
}
