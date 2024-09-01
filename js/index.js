getSelectedTab; //FUNCTION CALL
loadInitialData("sevenDays");
connectMe("metamask_wallet");
let userAddress = Web3.eth.getAccounts();
userAddress = userAddress[0]; // Use the first account as the current address
async function connectWallet() {
  const accounts = await ethereum.request({ method: "eth_requestAccounts" });
  currentAddress = accounts[0];
  console.log("Connected address:", currentAddress);
}

function openTab(event, name) {
  console.log(name);
  contractCall = name;
  getSelectedTab(name);
  loadInitialData(name);
}
async function loadInitialData(sClass) {
  console.log(sClass);

  try {
    await connectWallet();
    clearInterval(countDownGlobal);
    if (!web3Main || !currentAddress) {
      throw new Error("Web3 or wallet address not initialized.");
    }

    let cObj = new web3Main.eth.Contract(
      SELECT_CONTRACT[_NETWORK_ID].STACKING.abi,
      SELECT_CONTRACT[_NETWORK_ID].STACKING[sClass].address
    );
    //ID ELEMENT DATA
    let totalUsers = await cObj.methods.getTotalUsers().call();
    let cApy = await cObj.methods.getAPY().call();
    console.log("APY", cApy);
    //GET USER
    let userDetail = await cObj.methods.getUser(currentAddress).call();
    const user = {
      lastRewardCalculationTime: userDetail.lastRewardCalculationTime,
      lastStakeTime: userDetail.lastStakeTime,
      rewardAmount: userDetail.rewardAmount,
      rewardsClaimedSoFar: userDetail.rewardsClaimedSoFar,
      stakeAmount: userDetail.stakeAmount,
      address: currentAddress,
    };
    localStorage.setItem("User", JSON.stringify(user));
    let userDetailBal = userDetail.stakeAmount / 10 ** 18;
    document.getElementById(
      "total-locked-user-token"
    ).innerHTML = `${userDetailBal}`;
    //ELEMENTS -ID
    document.getElementById(
      "num-of-stackers-value"
    ).innerHTML = `${totalUsers}`;
    document.getElementById("apy-value-feature").innerHTML = `${cApy}% `;
    //CLASS ELEMENT DATA
    let totalLockedTokens = await cObj.methods.getTotalStakedTokens().call();
    let earlyUnstakeFee = await cObj.methods
      .getEarlyUnstakeFeePercentage()
      .call();
    // ELEMENTS --CLASS
    document.getElementById("total-locked-tokens-value").innerHTML = `${
      totalLockedTokens / 10 ** 18
    } ${SELECT_CONTRACT[_NETWORK_ID].TOKEN.symbol}`;
    document
      .querySelectorAll(".early-unstake-fee-value")
      .forEach(function (element) {
        element.innerHTML = `${earlyUnstakeFee / 100} %`;
      });
    let minStakeAmount = await cObj.methods.getMinimumStakingAmount().call();
    minStakeAmount = Number(minStakeAmount);
    let minA;
    if (minStakeAmount) {
      minA = `${(minStakeAmount / 10 ** 18).toLocaleString()} ${
        SELECT_CONTRACT[_NETWORK_ID].TOKEN.symbol
      }`;
    } else {
      minA = "N/A";
    }
    document
      .querySelectorAll(".Minimum-Staking-Amount")
      .forEach(function (element) {
        element.innerHTML = `${minA}`;
      });
    document
      .querySelectorAll(".Maximum-Staking-Amount")
      .forEach(function (element) {
        element.innerHTML = `${(5000).toLocaleString()} ${
          SELECT_CONTRACT[_NETWORK_ID].TOKEN.symbol
        }`;
      });
    let isStakingPaused = await cObj.methods.getStakingStatus().call();
    let isStakingPausedText;
    let startDate = await cObj.methods.getStakeStartDate().call();
    startDate = Number(startDate) * 1000;
    let endDate = await cObj.methods.getStakeEndDate().call();
    endDate = Number(endDate) * 1000;
    let stakeDays = await cObj.methods.getStakeDays().call();
    let days = Math.floor(Number(stakeDays) / (3600 * 24));
    let dayDisplay = days > 0 ? days + (days == 1 ? " day, " : "days, ") : "";
    document.querySelectorAll(".Lock-period-value").forEach(function (element) {
      element.innerHTML = `${dayDisplay}`;
    });
    let rewardBal = await cObj.methods
      .getUserEstimatedRewards()
      .call({ from: currentAddress });
    document.getElementById("user-reward-balance-value").value = `Reward: ${
      rewardBal / 10 ** 18
    } ${SELECT_CONTRACT[_NETWORK_ID].TOKEN.symbol}`;
    //USER TOKEN BALANCE
    console.log("SELECT_CONTRACT[_NETWORK_ID]:", SELECT_CONTRACT[_NETWORK_ID]);
    if (!web3) {
      console.log("Web3 is not initialized!");
    } else {
      console.log("Web3 is initialized", web3);
    }

    oContractToken = new web3.eth.Contract(
      SELECT_CONTRACT[_NETWORK_ID].TOKEN.abi,
      SELECT_CONTRACT[_NETWORK_ID].TOKEN.address
    );

    console.log("oContractToken after initialization:", oContractToken);
    // console.log("oContractToken:", oContractToken);
    let balMainUser = currentAddress
      ? await oContractToken.methods.balanceOf(currentAddress).call()
      : "";
    balMainUser = Number(balMainUser) / 10 ** 18;
    document.getElementById(
      "user-token-balance"
    ).innerHTML = `Balance: ${balMainUser}`;
    let currentDate = new Date().getTime();
    if (isStakingPaused) {
      isStakingPausedText = "Paused";
    } else if (currentDate < startDate) {
      isStakingPausedText = "Locked";
    } else if (currentDate > endDate) {
      isStakingPausedText = "Ended";
    } else {
      isStakingPausedText = "Active";
    }
    document
      .querySelectorAll(".active-status-stacking")
      .forEach(function (element) {
        element.innerHTML = `${isStakingPausedText}`;
      });
    if (currentDate > startDate && currentDate < endDate) {
      const ele = document.getElementById("countdown-time-value");
      generateCountDown(ele, endDate);
      document.getElementById(
        "countdown-title-value"
      ).innerHTML = `Staking Ends In`;
    }

    if (currentDate < startDate) {
      const ele = document.getElementById("countdown-time-value");
      generateCountDown(ele, endDate);
      document.getElementById(
        "countdown-title-value"
      ).innerHTML = `Staking Starts In`;
    }
    document.querySelectorAll(".apy-value").forEach(function (element, index) {
      element.innerHTML = `${cApy} %`;
    });
  } catch (error) {
    console.log(error);
    notyf.error(
      `Unable to fetch data from ${SELECT_CONTRACT[_NETWORK_ID].network_name}! \n Please refresh this page.`
    );
  }
}
function generateCountDown(ele, claimDate) {
  clearInterval(countDownGlobal);
  //Set the date we're counting down to
  var countDownDate = new Date(claimDate).getTime();
  countDownGlobal = setInterval(function () {
    var now = new Date().getTime();
    // Find the distance between now and the count down date
    var distance = countDownDate - now;
    // Time calculations for days, hours, minutes and seconds
    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
    var hours = Math.floor(
      (distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)
    );
    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((distance % (1000 * 60)) / 1000);
    // Display the result in the element
    ele.innerHTML = days + "d" + hours + "h" + minutes + "m" + seconds + "s";
    // ele.html(days + "d" + hours + "h + minutes + "m" seconds + "s ");
    // If the count down is finished, write some text
    if (distance < 0) {
      clearInterval(countDownGlobal);
      ele.html("Refresh Page");
    }
  }, 1000);
}
async function connectMe(_provider) {
  try {
    let _comn_res = await commonProviderDetector(_provider);
    console.log(_comn_res);
    if (!_comn_res) {
      onsole.log("Please Connect");
    } else {
      let sClass = getSelectedTab();
      console.log(sClass);
    }
  } catch (error) {
    notyf.error(error.message);
  }
}
async function stakeTokens() {
  try {
    let nTokens = document.getElementById("amount-to-stack-value-new").value;
    if (!nTokens) {
      console.log("No tokens entered.");
      return;
    }

    if (isNaN(nTokens) || nTokens == 0 || Number(nTokens) < 0) {
      console.log("Invalid token amount!");
      return;
    }

    nTokens = Number(nTokens);
    let tokenToTransfer = addDecimal(nTokens, 18);
    console.log("Tokens to Transfer:", tokenToTransfer);

    let balMainUser = await oContractToken.methods
      .balanceOf(currentAddress)
      .call();
    balMainUser = Number(balMainUser) / 10 ** 18;
    console.log("User Balance:", balMainUser);

    if (balMainUser < nTokens) {
      notyf.error(`
          Insufficient tokens on ${SELECT_CONTRACT[_NETWORK_ID].network_name}.\nPlease
          buy some tokens first!`);
      return;
    }

    let sClass = getSelectedTab(contractCall);
    console.log("Selected Tab Class:", sClass);

    let balMainAllowance = await oContractToken.methods
      .allowance(
        currentAddress,
        SELECT_CONTRACT[_NETWORK_ID].STACKING[sClass].address
      )
      .call();

    console.log("Allowance:", balMainAllowance);

    if (Number(balMainAllowance) < Number(tokenToTransfer)) {
      console.log(
        "Allowance is less than token to transfer, calling approveTokenSpend..."
      );
      approveTokenSpend(tokenToTransfer, sClass);
    } else {
      console.log("Allowance is sufficient, proceeding with staking...");
      stakeTokenMain(tokenToTransfer, sClass);
    }
  } catch (error) {
    console.error("Error in stakeTokens:", error);
    notyf.dismiss(notification);
    notyf.error(formatEthErrorMsg(error));
  }
}

async function approveTokenSpend(_mint_fee_wei, sClass) {
  let gasEstimation;
  try {
    console.log("Approving token spend...");

    if (!currentAddress) {
      console.error("No currentAddress found. Cannot approve token spend.");
      notyf.error("Wallet not connected. Please try again.");
      return;
    }

    gasEstimation = await oContractToken.methods
      .approve(
        SELECT_CONTRACT[_NETWORK_ID].STACKING[sClass].address,
        _mint_fee_wei
      )
      .estimateGas({ from: currentAddress });

    console.log("Gas Estimation for approve:", gasEstimation);
    console.log(
      "approve",
      SELECT_CONTRACT[_NETWORK_ID].STACKING[sClass].address
    );
    await oContractToken.methods
      .approve(
        SELECT_CONTRACT[_NETWORK_ID].STACKING[sClass].address,
        _mint_fee_wei
      )
      .send({
        from: currentAddress,
        gas: gasEstimation,
      })
      .on("transactionHash", (hash) => {
        console.log("Transaction Hash:", hash);
      })
      .on("receipt", (receipt) => {
        console.log("Approval Receipt:", receipt);
        stakeTokenMain(_mint_fee_wei, sClass);
      })
      .catch((error) => {
        console.log("Error during approve transaction:", error);
        notyf.error(formatEthErrorMsg(error));
      });
  } catch (error) {
    console.error("Error in approveTokenSpend:", error);
    notyf.error(formatEthErrorMsg(error));
  }
}
async function stakeTokenMain(_amount_wei, sClass) {
  let gasEstimation;
  let oContractStacking = getContractObj(sClass);
  try {
    gasEstimation = await oContractStacking.methods
      .stake(_amount_wei)
      .estimateGas({ from: currentAddress });
  } catch (error) {
    console.log(error);
    notyf.error(formatEthErrorMsg(error));
    return;
  }
  oContractStacking.methods
    .stake(_amount_wei)
    .send({ from: currentAddress, gas: gasEstimation })
    .on("receipt", (receipt) => {
      console.log(receipt);
      const receiptObj = {
        token: _amount_wei,
        from: receipt.from,
        to: receipt.to,
        blockHash: receipt.blockHash,
        blockNumber: receipt.blockNumber,
        cumulativeGasUsed: receipt.cumulativeGasUsed,
        effectiveGasPrice: receipt.effectiveGasPrice,
        gasUsed: receipt.gasUsed,
        status: receipt.status,
        transactionHash: receipt.transactionHash,
        type: receipt.type,
      };
      let transactionHistory = [];
      const allUserTransactions = localStorage.getItem("transactions");
      if (allUserTransactions) {
        transactionHistory = JSON.parse(localStorage.getItem("transactions"));
        transactionHistory.push(receiptObj);
        localStorage.setItem(
          "transactions",
          JSON.stringify(transactionHistory)
        );
      } else {
        transactionHistory.push(receiptObj);
        localStorage.setItem("transaction", JSON.stringify(transactionHistory));
      }
      console.log(allUserTransactions);
      window.location.href = "http://127.0.0.1:5500/analytic.html";
    })
    .on("transactionHash", (hash) => {
      console.log("Transaction Hash", hash);
    })
    .catch((error) => {
      console.log(error);
      notyf.error(formatEthErrorMsg(error));
      return;
    });
}
//on function is an event listener in JavaScript that listens for specific events and triggers a callback when the event occurs.
//the first argument in the .on function represents a predefined event string

async function unstackTokens() {
  try {
    let nTokens = document.getElementById("amount-to-unstack-value").value;
    if (!nTokens) {
      return;
    }
    if (isNaN(nTokens) || nTokens == 0 || Number(nTokens) < 0) {
      notyf.error("Invalid token amount!");
      return;
    }
    nTokens = Number(nTokens);
    let tokenToTransfer = addDecimal(nTokens, 18);
    let sClass = getSelectedTab(contractCall);
    let oContractStacking = getContractObj(sClass);
    let balMainUser = await oContractStacking.methods
      .getUser(currentAddress)
      .call();
    balMainUser = Number(balMainUser.stakeAmount) / 10 ** 18;
    if (balMainUser < nTokens) {
      notyf.error(
        `insufficient staked tokens on ${SELECT_CONTRACT[_NETWORK_ID].network_name}!`
      );
      return;
    }
    unstackTokenMain(tokenToTransfer, oContractStacking, sClass);
  } catch (error) {
    console.log(error);
    notyf.dismiss(notification);
    notyf.error(formatEthErrorMsg(error));
  }
}
async function unstackTokenMain(_amount_wei, oContractStacking, sClass) {
  let gasEstimation;
  try {
    gasEstimation = await oContractStacking.methods
      .unstake(_amount_wei)
      .estimateGas({ from: currentAddress });
  } catch (error) {
    console.log(error);
    notyf.error(formatEthErrorMsg(error));
    return;
  }
  oContractStacking.methods
    .unstake(_amount_wei)
    .send({ from: currentAddress, gas: gasEstimation })
    .on("receipt", (receipt) => {
      console.log(receipt);
      const receipt0bj = {
        token: _amount_wei,
        from: receipt.from,
        to: receipt.to,
        blockHash: receipt.blockHash,
        blockNumber: receipt.blockNumber,
        cumulativeGasUsed: receipt.cumulativeGasUsed,
        effectiveGasPrice: receipt.effectiveGasPrice,
        gasUsed: receipt.gasUsed,
        status: receipt.status,
        transactionHash: receipt.transactionHash,
        type: receipt.type,
      };
      let transactionHistory = [];
      const allUserTransaction = localStorage.getItem("transactions");
      if (allUserTransaction) {
        transactionHistory = JSON.parse(localStorage.getItem("transactions"));
        transactionHistory.push(receiptObj);
        localStorage.setItem(
          "transactions",
          JSON.stringify(transactionHistory)
        );
      } else {
        transactionHistory.push(receiptObj);
        localStorage.setItem(
          "transactions",
          JSON.stringify(transactionHistory)
        );
      }
      window.location.href = "http://127.0.0.1:5500/analytic.html";
    })
    .on("transactionHash", (hash) => {
      console.log("Transaction Hash: ", hash);
    })
    .catch((error) => {
      console.log(error);
      notyf.error(formatEthErrorMsg(error));
      return;
    });
}
async function claimTokens() {
  try {
    let sClass = getSelectedTab(contractCall);
    let oContractStacking = getContractObj(sClass);
    let rewardBal = await oContractStacking.methods
      .getUserEstimatedRewards()
      .call({ from: currentAddress });
    rewardBal = Number(rewardBal);
    console.log("rewardBal", rewardBal);
    if (!rewardBal) {
      notyf.dismiss(notification);
      notyf.error(`insufficient reward tokens to claim!`);
    }
    claimTokenMain(oContractStacking, sClass);
  } catch (error) {
    console.log(error);
    notyf.dismiss(notification);
    notyf.error(formatEthErrorMsg(error));
  }
}
async function claimTokenMain(oContractStacking, sClass) {
  try {
    // Estimate gas for the claimReward transaction
    const gasEstimation = await oContractStacking.methods
      .claimReward()
      .estimateGas({ from: currentAddress });

    console.log("Gas Estimation:", gasEstimation);

    // Send the claimReward transaction
    oContractStacking.methods
      .claimReward()
      .send({
        from: currentAddress,
        gas: gasEstimation,
      })
      .on("transactionHash", (hash) => {
        console.log("Transaction Hash:", hash);
      })
      .on("receipt", (receipt) => {
        console.log("Transaction Receipt:", receipt);

        // Create a receipt object for storing
        const receiptObj = {
          from: receipt.from,
          to: receipt.to,
          blockHash: receipt.blockHash,
          blockNumber: receipt.blockNumber,
          cumulativeGasUsed: receipt.cumulativeGasUsed,
          effectiveGasPrice: receipt.effectiveGasPrice,
          gasUsed: receipt.gasUsed,
          status: receipt.status,
          transactionHash: receipt.transactionHash,
          type: receipt.type,
        };

        // Update transaction history in localStorage
        let transactionHistory =
          JSON.parse(localStorage.getItem("transactions")) || [];
        transactionHistory.push(receiptObj);
        localStorage.setItem(
          "transactions",
          JSON.stringify(transactionHistory)
        );

        // Redirect to analytics page
        window.location.href = "http://127.0.0.1:5500/analytic.html";
      })
      .on("error", (error) => {
        console.log("Transaction Error:", error);
        notyf.error(formatEthErrorMsg(error));
      });
  } catch (error) {
    console.log("Error Estimating Gas:", error);
    notyf.error(formatEthErrorMsg(error));
  }
}
