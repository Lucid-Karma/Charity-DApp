import React, { useState, useEffect } from 'react';
import Register from './components/Register';
import Vote from './components/Vote';
import Donate from './components/Donate';
import { init, getUserAddress, register, vote, donate } from './Web3User';
import './App.css';

const App = () => {
  const [userAddress, setUserAddress] = useState('');
  const [name, setName] = useState('');
  const [surname, setSurname] = useState('');
  const [voteNumber, setVoteNumber] = useState('');
  const [donationAmount, setDonationAmount] = useState('');
  const [isRegistered, setIsRegistered] = useState(false);

  const handleRegister = async (name, surname) => {
    await register(name, surname);
    console.log('User registered successfully!');
    setIsRegistered(true);
  };

  const handleVote = async () => {
    if (voteNumber !== '') {
      await vote(Number(voteNumber));
      console.log('Voted successfully!');
      setVoteNumber('');
    }
  };

  const handleDonate = async () => {
    if (donationAmount !== '') {
      await donate(Number(donationAmount));
      console.log('Donated successfully!');
      setDonationAmount('');
    }
  };

  useEffect(() => {
    const initWeb3 = async () => {
      await init();
      const address = await getUserAddress();
      setUserAddress(address);
    };
    initWeb3();
  }, []);

  return (
    <div className="app-container">
      <div className="header">
        <h1>Safe Contract dApp</h1>
      </div>

      <div className="user-info">
        <h2>User Info</h2>
        <p>User Address: {userAddress}</p>
      </div>

      {!isRegistered && <Register onRegister={handleRegister} />}

      {isRegistered && (
        <div>
          <div className="action-section">
            <Vote onVote={handleVote} />
          </div>

          <div className="action-section">
            <Donate onDonate={handleDonate} />
          </div>
        </div>
      )}
    </div>
  );
};

export default App;
