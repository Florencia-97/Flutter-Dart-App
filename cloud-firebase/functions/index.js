const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendOrderTakenNotification = functions.database.ref('/order/{userUid}/taken/{orderId}')
    .onWrite(async (change, context) => {
      const userUid = context.params.userUid;
      const orderId = context.params.orderId;
      const requesterId = change.after._data.requestedUserId;
      const realOrderId = change.after._data.requestedOrderId;

      console.log('New order taken ID:', realOrderId, 'by user:', userUid, 'for user:', requesterId );


      let snapshot = await admin.database().ref(`/order/${requesterId}/requested`).once('value');
      const orderData = snapshot.child(realOrderId).val();
      console.log(orderData);

      const getDeviceTokensPromise = admin.database()
          .ref(`/users/${requesterId}/notificationToken`).once('value');

      // podria estar bueno tener el id del usuario que tomo el pedido
      //const getFollowerProfilePromise = admin.auth().getUser(userCapoId);

      // The snapshot to the user's tokens.
      let tokensSnapshot;

      // The array containing all the user's tokens.
      let tokens;

      const results = await Promise.all([getDeviceTokensPromise]);//, getFollowerProfilePromise]);
      tokensSnapshot = results[0];
      //const follower = results[1];

      // Check if there are any device tokens.
      if (!tokensSnapshot.hasChildren()) {
        return console.log('There are no notification tokens to send to.');
      }
      console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
      //console.log('Fetched follower profile', follower);

      // Notification details.
      const payload = {
        notification: {
          title: 'Alguien tomo tu pedido!',
          body: `El pedido: "${orderData.title}" al aula: ${orderData.classroom} esta en curso.`,
          //icon: follower.photoURL
        }
      };

      // Listing all tokens as an array.
      tokens = Object.keys(tokensSnapshot.val());
      console.log(tokens);
      // Send notifications to all tokens.
      const response = await admin.messaging().sendToDevice(tokens, payload);
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });

exports.sendOrderFinishedNotification = functions.database.ref('/order/{userUid}/requested/{orderId}')
    .onUpdate(async (change, context) => {
      const userUid = context.params.userUid;
      const tokensToRemove = [];

      if (change.after._data.status === 'resolved') {
          const getDeviceTokensPromise = admin.database()
            .ref(`/users/${userUid}/notificationToken`).once('value');

        // The snapshot to the user's tokens.
        let tokensSnapshot;

        // The array containing all the user's tokens.
        let tokens;

        const results = await Promise.all([getDeviceTokensPromise]);//, getFollowerProfilePromise]);
        tokensSnapshot = results[0];
        //const follower = results[1];

        // Check if there are any device tokens.
        if (!tokensSnapshot.hasChildren()) {
          return console.log('There are no notification tokens to send to.');
        }
        console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
        //console.log('Fetched follower profile', follower);

        // Notification details.
        const payload = {
          notification: {
            title: 'Tu pedido esta afuera!',
            body: `El pedido: "${change.after._data.title}" se encuentra afuera del aula: ${change.after._data.classroom}.`,
            //icon: follower.photoURL
          }
        };

        // Listing all tokens as an array.
        tokens = Object.keys(tokensSnapshot.val());
        console.log(tokens);
        // Send notifications to all tokens.
        const response = await admin.messaging().sendToDevice(tokens, payload);
        // For each message check if there was an error.
        
        response.results.forEach((result, index) => {
          const error = result.error;
          if (error) {
            console.error('Failure sending notification to', tokens[index], error);
            // Cleanup the tokens who are not registered anymore.
            if (error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered') {
              tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
            }
          }
        });
      }
      return Promise.all(tokensToRemove);
    });

exports.sendMessageNotification = functions.database.ref('/chat/{orderId}/messages/{messageId}')
    .onWrite(async (change, context) => {
      const orderId = context.params.orderId;
      const senderId = change.after._data.userId;

      let snapshotChat = await admin.database().ref(`/chat/${orderId}`).once('value');
      let chatData = snapshotChat.val();
      console.log(chatData);

      let snapshotOrder = await admin.database().ref(`/order/${chatData.requesterUserId}/requested`).once('value');
      let orderData = snapshotOrder.child(orderId).val();
      console.log(orderData);

      const recieverId = senderId === chatData.requesterUserId ? chatData.takerUserId : chatData.requesterUserId;
      

      const getDeviceTokensPromise = admin.database()
          .ref(`/users/${recieverId}/notificationToken`).once('value');

      // podria estar bueno tener el id del usuario que tomo el pedido
      //const getFollowerProfilePromise = admin.auth().getUser(userCapoId);

      // The snapshot to the user's tokens.
      let tokensSnapshot;

      // The array containing all the user's tokens.
      let tokens;

      const results = await Promise.all([getDeviceTokensPromise]);//, getFollowerProfilePromise]);
      tokensSnapshot = results[0];
      //const follower = results[1];

      // Check if there are any device tokens.
      if (!tokensSnapshot.hasChildren()) {
        return console.log('There are no notification tokens to send to.');
      }
      console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
      //console.log('Fetched follower profile', follower);

      // Notification details.
      const payload = {
        notification: {
          title: `${orderData.title}`,
          body: `Tu wafi: ${change.after._data.text}`,
          //icon: follower.photoURL
        }
      };

      // Listing all tokens as an array.
      tokens = Object.keys(tokensSnapshot.val());
      console.log(tokens);
      // Send notifications to all tokens.
      const response = await admin.messaging().sendToDevice(tokens, payload);
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });