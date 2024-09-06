import redis

from flask import Flask, render_template
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired
from flask_bootstrap import Bootstrap
from flask_wtf import FlaskForm
import hashlib
import os



bootstrap = Bootstrap()
key = os.urandom(32)

app = Flask(__name__, template_folder='.')

app.config['SECRET_KEY'] = key
bootstrap.init_app(app)

#nodes = [red.cluster.ClusterNode("localhost", 6379, server_type='primary'),
#         red.cluster.ClusterNode("localhost", 6380, server_type='primary')]
#rc = red.cluster.RedisCluster(startup_nodes=nodes, decode_responses=True)

rc = redis.Redis(host="localhost", port=6379, decode_responses=True)

class PostForm(FlaskForm):
    body = StringField('Enter URL: ', validators=[DataRequired()])
    submit = SubmitField('Submit')
    
    
@app.route('/home', methods=["GET", "POST"])
def home():
    form: PostForm = PostForm()
    full_url = form.body.data
    short_url=None
    if full_url:
        short_url = rc.get(full_url)
        if short_url:
            return render_template('base.html', form=form, short_url=short_url,
                                full_url=full_url)
        hash = hashlib.new('sha256')
        hash.update(bytes(full_url, encoding='utf-8'))
        short_url = hash.hexdigest()[:6]
        
        
        rc.set(full_url, short_url)    
    return render_template('base.html', form=form, short_url=short_url,
                               full_url=full_url)

if __name__ == '__main__':
    app.run(debug=True)
    