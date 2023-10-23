import React, { useState } from 'react';

const Register = ({ onRegister }) => {
  const [name, setName] = useState('');
  const [surname, setSurname] = useState('');

  const handleRegister = () => {
    onRegister(name, surname);
  };

  return (
    <div>
      <h2>Register User</h2>
      <label>
        Name:
        <input type="text" value={name} onChange={(e) => setName(e.target.value)} />
      </label>
      <label>
        Surname:
        <input type="text" value={surname} onChange={(e) => setSurname(e.target.value)} />
      </label>
      <button onClick={handleRegister}>Register</button>
    </div>
  );
};

export default Register;
