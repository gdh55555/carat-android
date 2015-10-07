package edu.berkeley.cs.amplab.carat.android.ui.adapters;

import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.media.Image;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.Button;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.HashMap;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.activities.DashboardActivity;
import edu.berkeley.cs.amplab.carat.android.dialogs.BaseDialog;
import edu.berkeley.cs.amplab.carat.android.protocol.ClickTracking;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;
import edu.berkeley.cs.amplab.carat.android.subscreens.KillAppFragment;

/**
 * Created by Valto on 2.10.2015.
 */
public class ActionsExpandListAdapter extends BaseExpandableListAdapter implements ExpandableListView.OnGroupExpandListener,
        ExpandableListView.OnChildClickListener, View.OnClickListener {

    private CaratApplication caratApplication;
    private SimpleHogBug[] hogReport, bugReport;
    private ArrayList<SimpleHogBug> allReports = new ArrayList<>();
    private LayoutInflater mInflater;
    private ExpandableListView lv;
    private ImageView collapseIcon;
    private DashboardActivity dashboardActivity;
    private Button killAppButton;

    private ImageView processIcon;
    private TextView processName;
    private TextView processImprovement;
    private TextView samplesAmount;
    private TextView appCategory;


    public ActionsExpandListAdapter(DashboardActivity dashboardActivity, ExpandableListView lv, CaratApplication caratApplication,
                                    SimpleHogBug[] hogReport, SimpleHogBug[] bugReport) {

        this.caratApplication = caratApplication;
        this.hogReport = hogReport;
        this.bugReport = bugReport;
        this.lv = lv;
        this.lv.setOnGroupExpandListener(this);
        this.dashboardActivity = dashboardActivity;
        this.lv.setOnChildClickListener(this);

        for (SimpleHogBug s : hogReport) {
            allReports.add(s);
        }
        for (SimpleHogBug s : bugReport) {
            allReports.add(s);
        }

        mInflater = LayoutInflater.from(caratApplication);

    }

    @Override
    public Object getChild(int groupPosition, int childPosition) {
        return childPosition;
    }

    @Override
    public long getChildId(int groupPosition, int childPosition) {
        return childPosition;
    }

    @Override
    public View getChildView(int groupPosition, int childPosition,
                             boolean isLastChild, View convertView, ViewGroup parent) {

        if (convertView == null) {
            LayoutInflater infalInflater = (LayoutInflater) caratApplication.getApplicationContext()
                    .getSystemService(caratApplication.getApplicationContext().LAYOUT_INFLATER_SERVICE);
            convertView = infalInflater.inflate(R.layout.bug_hog_list_child_item, null);
        }

        SimpleHogBug item = allReports.get(groupPosition);
        setViewsInChild(convertView, item);
        return convertView;
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return 1;
    }

    @Override
    public Object getGroup(int groupPosition) {
        return allReports.get(groupPosition);
    }

    @Override
    public int getGroupCount() {
        return allReports.size();
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded,
                             View convertView, ViewGroup parent) {
        if (convertView == null) {
            LayoutInflater inf = (LayoutInflater) caratApplication.getApplicationContext()
                    .getSystemService(caratApplication.getApplicationContext().LAYOUT_INFLATER_SERVICE);
            convertView = inf.inflate(R.layout.bug_hog_list_header, null);
        }

        if (allReports == null || groupPosition < 0
                || groupPosition >= allReports.size())
            return convertView;

        SimpleHogBug item = allReports.get(groupPosition);
        if (item == null)
            return convertView;

        setItemViews(convertView, item, groupPosition);

        return convertView;
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }

    @Override
    public boolean isChildSelectable(int groupPosition, int childPosition) {
        return true;
    }

    private void setViewsInChild(View v, SimpleHogBug item) {
        TextView samplesText = (TextView) v.findViewById(R.id.samples_title);
        samplesAmount = (TextView) v.findViewById(R.id.samples_amount);
        killAppButton = (Button) v.findViewById(R.id.stop_app_button);
        appCategory = (TextView) v.findViewById(R.id.app_category);

        samplesText.setText(R.string.samples);
        samplesAmount.setText(String.valueOf(item.getSamples()));

        killAppButton.setOnClickListener(this);

    }

    private void setItemViews(View v, SimpleHogBug item, int groupPosition) {
        processIcon = (ImageView) v.findViewById(R.id.process_icon);
        processName = (TextView) v.findViewById(R.id.process_name);
        processImprovement = (TextView) v.findViewById(R.id.process_improvement);
        collapseIcon = (ImageView) v.findViewById(R.id.collapse_icon);

        processIcon.setImageDrawable(CaratApplication.iconForApp(caratApplication.getApplicationContext(),
                item.getAppName()));
        processName.setText(CaratApplication.labelForApp(caratApplication.getApplicationContext(),
                item.getAppName()));
        processImprovement.setText(item.getBenefitText());
        collapseIcon.setImageResource(R.drawable.collapse_down);
        collapseIcon.setTag(groupPosition);
    }

    // TODO COLLAPSE IMAGES NOT WORKING
    @Override
    public void onGroupExpand(int groupPosition) {

    }

    @Override
    public void onGroupCollapsed(int groupPosition) {
    }

    @Override
    public boolean onChildClick(ExpandableListView parent, View v, int groupPosition, int childPosition, long id) {
        return true;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.stop_app_button:
                // TODO KILL APP GET ITEM
                // killApp();
                break;
        }
    }

    public void killApp(SimpleHogBug fullObject) {
        final String raw = fullObject.getAppName();
        final PackageInfo pak = SamplingLibrary.getPackageInfo(dashboardActivity, raw);
        final String label = CaratApplication.labelForApp(dashboardActivity, raw);

        if (raw.equals("OsUpgrade")) {
            //m.showHTMLFile("upgradeos", dashboardActivity.getString(R.string.upgradeosinfo), false);
        } else if (raw.equals(dashboardActivity.getString(R.string.helpcarat))) {
            //m.showHTMLFile("collectdata", dashboardActivity.getString(R.string.collectdatainfo), false);
        } else if (raw.equals(dashboardActivity.getString(R.string.questionnaire))) {
            //openQuestionnaire();
        } else {
            SharedPreferences p = PreferenceManager.getDefaultSharedPreferences(dashboardActivity);
            if (p != null) {
                String uuId = p.getString(CaratApplication.getRegisteredUuid(), "UNKNOWN");
                HashMap<String, String> options = new HashMap<String, String>();
                if (pak != null) {
                    options.put("app", pak.packageName);
                    options.put("version", pak.versionName);
                    options.put("versionCode", pak.versionCode + "");
                    options.put("label", label);
                }
                options.put("benefit", samplesAmount.getText().toString().replace('\u00B1', '+'));
                ClickTracking.track(uuId, "killbutton", options, caratApplication);
            }

            killAppButton.setEnabled(false);
            killAppButton.setText(caratApplication.getString(R.string.killed));
            SamplingLibrary.killApp(dashboardActivity, raw, label);

        }
    }
}
