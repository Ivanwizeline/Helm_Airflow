# To generate a new fernet encryption key

```bash
python ../secrets/fernet.py
```


Fernet
Airflow uses Fernet to encrypt passwords in the connection configuration and the variable configuration. It guarantees that a password encrypted using it cannot be manipulated or read without the key. Fernet is an implementation of symmetric (also known as “secret key”) authenticated cryptography.

The first time Airflow is started, the airflow.cfg file is generated with the default configuration and the unique Fernet key. The key is saved to option fernet_key of section [core].

You can also configure a fernet key using environment variables. This will overwrite the value from the airflow.cfg file

# Note the double underscores
```bash
export AIRFLOW__CORE__FERNET_KEY=your_fernet_key
```

### Generating Fernet key
If you need to generate a new fernet key you can use the following code snippet.

```py
from cryptography.fernet import Fernet

fernet_key = Fernet.generate_key()
print(fernet_key.decode())  # your fernet_key, keep it in secured place!
```

### Rotating encryption keys

Once connection credentials and variables have been encrypted using a fernet key, changing the key will cause decryption of existing credentials to fail. To rotate the fernet key without invalidating existing encrypted values, prepend the new key to the fernet_key setting, run airflow rotate-fernet-key, and then drop the original key from fernet_key:

Set fernet_key to new_fernet_key,old_fernet_key

Run airflow rotate-fernet-key to re-encrypt existing credentials with the new fernet key

Set fernet_key to new_fernet_key
