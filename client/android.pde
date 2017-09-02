import android.app.Activity;
import   android.content.Context;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.text.Editable;
import   android.graphics.Color;
import android.widget.Toast;
import android.os.Looper;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.os.Bundle;
import android.widget.EditText;
import android.widget.Button;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;
import android.view.KeyEvent;
import android.text.TextWatcher;
import android.os.StrictMode;

EditText edit;
Button btn;
Activity act;
Context mC;
FrameLayout fl;

@Override
  public void onStart() {
  super.onStart();
  
  //network threading
  //StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
  //StrictMode.setThreadPolicy(policy); 
  

  act = this.getActivity();
  mC= act.getApplicationContext();
  act.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);

  //create base view to fit screen
  RelativeLayout base = new RelativeLayout(mC);
  RelativeLayout.LayoutParams baseLayout = new  RelativeLayout.LayoutParams(
    RelativeLayout.LayoutParams.MATCH_PARENT, 
    RelativeLayout.LayoutParams.MATCH_PARENT);
  base.setLayoutParams(baseLayout);


  //create editable text box: layout
  RelativeLayout.LayoutParams editlayout = new RelativeLayout.LayoutParams( 
    width * 2 / 3, 
    RelativeLayout.LayoutParams.WRAP_CONTENT
    );
  editlayout.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
  editlayout.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
  editlayout.setMargins(20, 20, 20, 20);
  //create editable text box view object
  edit = new EditText(mC);
  edit.setLayoutParams(editlayout);
  edit.setHint("insert a message");
  edit.setTextColor(Color.rgb(200, 0, 0));
  edit.setBackgroundColor(Color.parseColor(colorsA[clientId]));
  edit.requestFocus();
  
  //restrict input to 2 lines
  edit.addTextChangedListener(new EditTextLinesLimiter(edit, 2));

  //handle enter key event
  edit.setOnKeyListener(new View.OnKeyListener() {
    public boolean onKey(View view, int keyCode, KeyEvent event) {
      if ((keyCode == KeyEvent.KEYCODE_ENTER)) {
        String txt = edit.getText().toString();
        println(txt);
        edit.getText().clear();
        InputMethodManager imm = (InputMethodManager) act.getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(view.getWindowToken(), 00);
        //add txt(message) to messageList
        if (!txt.equals("")) {
          submitMessage(txt);
        }
        return true;
      }
      return false; //do not handle other keys
    }
  }
  );


  //create message submit button:layout
  RelativeLayout.LayoutParams btnlayout = new RelativeLayout.LayoutParams( 
    RelativeLayout.LayoutParams.WRAP_CONTENT, 
    RelativeLayout.LayoutParams.WRAP_CONTENT
    );
  btnlayout.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
  btnlayout.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
  btnlayout.setMargins(20, 20, 20, 20);

  //create message submit button object & listener
  btn = new Button(mC);
  btn.setText("submit");
  btn.setLayoutParams(btnlayout);
  btn.setOnClickListener(new OnClickListener() {
    public void onClick(View view) {
      String txt = edit.getText().toString();
      println(txt);
      edit.getText().clear();
      InputMethodManager imm = (InputMethodManager) act.getSystemService(Context.INPUT_METHOD_SERVICE);
      imm.hideSoftInputFromWindow(view.getWindowToken(), 00);
      //add txt(message) to messageList
      submitMessage(txt);
    }
  }
  );  

  base.addView(edit);
  base.addView(btn);

  fl = (FrameLayout)act.findViewById(0x1000);
  fl.addView(base);
}

public class EditTextLinesLimiter implements TextWatcher {
    private EditText editText;
    private int maxLines;
    private String lastValue = "";

    public EditTextLinesLimiter(EditText editText, int maxLines) {
        this.editText = editText;
        this.maxLines = maxLines;
    }

    public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
        lastValue = charSequence.toString();
    }

    public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

    }

    public void afterTextChanged(Editable editable) {
        if (editText.getLineCount() > maxLines) {
            int selectionStart = editText.getSelectionStart() - 1;
            editText.setText(lastValue);
            if (selectionStart >= editText.length()) {
                selectionStart = editText.length();
            }
            editText.setSelection(selectionStart);
        }
    }
}