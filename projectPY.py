from flask import Flask, request, render_template_string # pip install Flask
from datetime import datetime
import mysql.connector

app = Flask(__name__)

@app.route("/link", methods=["POST"])

def search_posts(media=None, start_date=None, end_date=None, username=None, first_name=None, last_name=None):
    db = mysql.connector.connect(
        host="localhost",
        user="your_username",
        password="your_password",
        database="your_database"
    )
    cursor = db.cursor(dictionary=True)

    query = """
        SELECT 
            Posts.text,
            Users.username,
            SocialMedia.name AS platform,
            Posts.time,
            GROUP_CONCAT(DISTINCT Projects.projectName) AS experiments
        FROM Posts
        JOIN Users ON Posts.userID = Users.id
        JOIN SocialMedia ON Users.socialMediaID = SocialMedia.id
        LEFT JOIN ProjectPosts ON Posts.id = ProjectPosts.postID
        LEFT JOIN Projects ON ProjectPosts.projectID = Projects.id
        WHERE 1 = 1
    """
    params = []

    if media:
        query += " AND LOWER(SocialMedia.name) = %s"
        params.append(media.lower())
    if username:
        query += " AND LOWER(Users.username) = %s"
        params.append(username.lower())
    if first_name:
        query += " AND LOWER(Users.firstName) = %s"
        params.append(first_name.lower())
    if last_name:
        query += " AND LOWER(Users.lastName) = %s"
        params.append(last_name.lower())
    if start_date and end_date:
        query += " AND Posts.time BETWEEN %s AND %s"
        params.extend([start_date, end_date])

    query += " GROUP BY Posts.id"

    cursor.execute(query, tuple(params))
    results = cursor.fetchall()

    for row in results:
        print(f"[{row['time']}] @{row['username']} on {row['platform']}")
        print(f"Text: {row['text']}")
        print(f"Experiments: {row['experiments'] or 'None'}\n")

    cursor.close()
    db.close()

@app.route("/search", methods=["POST"])
def search():
    media = request.form.get("media") or None
    username = request.form.get("username") or None
    first_name = request.form.get("first_name") or None
    last_name = request.form.get("last_name") or None
    start_date = request.form.get("start_date") or None
    end_date = request.form.get("end_date") or None

    def is_valid_date(date_str): # fallbacks
        try:
            datetime.strptime(date_str, "%Y-%m-%d")
            return True
        except (ValueError, TypeError):
            return False

    if not is_valid_date(start_date):
        start_date = None
    if not is_valid_date(end_date):
        end_date = None

    return search_posts( # returns all checks
        media=media,
        username=username,
        first_name=first_name,
        last_name=last_name,
        start_date=start_date,
        end_date=end_date
    )

def home():
    return render_template_string(open("link_post.html").read())

if __name__ == "__main__":
    app.run(debug=True)
    