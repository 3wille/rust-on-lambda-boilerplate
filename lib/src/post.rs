use std::future::Future;

use aws_sdk_dynamodb as dynamodb;
use chrono::{serde::ts_seconds, DateTime, Utc};
use serde::{Deserialize, Serialize};
use serde_dynamo::to_item;

#[derive(Serialize, Deserialize, Clone)]
pub struct Post {
    pub body: String,
    #[serde(with = "ts_seconds")]
    pub created_at: DateTime<Utc>,
}

impl Post {
    pub fn save(
        self,
        dynamodb_client: &dynamodb::Client,
    ) -> impl Future<
        Output = Result<
            dynamodb::operation::put_item::PutItemOutput,
            dynamodb::error::SdkError<dynamodb::operation::put_item::PutItemError>,
        >,
    > {
        let db_post: PostDB = self.clone().into();
        let item = to_item(db_post).unwrap();
        dynamodb_client
            .put_item()
            .table_name(table_name())
            .set_item(Some(item))
            .send()
    }
}

#[derive(Serialize, Deserialize)]
struct PostDB {
    pk: String,
    sk: String,
    body: String,
}

impl From<Post> for PostDB {
    fn from(post: Post) -> Self {
        PostDB {
            pk: "posts".into(),
            sk: post.created_at.to_rfc3339(),
            body: post.body,
        }
    }
}

fn table_name() -> String {
    std::env::var("DYNAMO_TABLE_NAME").unwrap()
}
